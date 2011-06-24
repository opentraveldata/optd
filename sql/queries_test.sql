--SELECT *
--FROM poi p1
--WHERE p1.graphid = '2536';
     
--SELECT DISTINCT *
--FROM poi p1
--WHERE st_dwithin(p1.place,
--       (SELECT place FROM poi p2 WHERE p2.graphid = '2536'),
--       200, false
--     );
     
SELECT DISTINCT p1.graphid FROM poi p1, poi p2 WHERE p2.graphid = '2536' AND p1.graphid <> p2.graphid AND ST_DWithin(p1.place, p2.place, 100000, false);     

--WHERE DISTANCE((SELECT place FROM poi p2 WHERE p2.graphid = 'http://localhost:7474/db/data/node/145'), p1.place) < 100

--SELECT *
--FROM SPATIAL_REF_SYS
--WHERE srid = 32661

