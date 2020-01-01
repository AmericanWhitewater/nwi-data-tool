CREATE VIEW nhd.nhdwaterbody AS
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0101
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0102
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0103
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0104
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0105
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0106
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0107
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0108
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0109
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0110
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0202
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0203
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0204
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0205
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0206
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0207
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0208
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0301
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0302
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0303
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0304
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0305
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0306
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0307
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0310
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0311
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0313
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0315
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0316
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0317
UNION ALL
SELECT comid::bigint AS nhdplusid, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       0 AS visibilityfilter
FROM nhdwaterbody_04
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0415
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0501
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0502
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0503
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0504
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0505
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0506
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0507
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0508
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0509
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0510
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0511
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0512
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0513
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0514
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0601
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0602
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0603
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0604
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0701
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0702
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0703
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0704
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0705
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0706
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0707
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0708
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0709
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0710
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0711
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0712
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0713
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0714
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0802
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0804
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0902
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_0903
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1002
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1003
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1004
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1007
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1008
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1009
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1012
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1015
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1017
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1018
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1019
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1021
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1024
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1027
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1030
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1101
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1102
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1105
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1106
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1107
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1108
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1109
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1111
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1113
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1114
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1201
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1202
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1203
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1205
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1206
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1207
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1209
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1210
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1211
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1301
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1302
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1304
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1306
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1307
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1401
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1402
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1403
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1404
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1405
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1406
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1407
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1408
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1501
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1502
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1503
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1504
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1505
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1506
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1601
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1602
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1603
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1605
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1701
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1702
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1703
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1704
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1705
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1706
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1707
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1708
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1709
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1710
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1711
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1712
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1801
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1802
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1803
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1804
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1805
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1806
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1807
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1808
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_1809
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_19020401
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_19020402
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_19020501
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_19020502
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_19020503
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_19020504
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_19020505
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_2001
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_2002
UNION ALL
SELECT nhdplusid::bigint, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       visibilityfilter
FROM nhdwaterbody_2007
UNION ALL
SELECT comid::bigint AS nhdplusid, geom,
       fdate,
       gnis_name,
       reachcode,
       fcode,
       0 AS visibilityfilter
FROM nhdwaterbody_21 ;