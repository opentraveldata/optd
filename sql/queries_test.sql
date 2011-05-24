SELECT DISTINCT p1.city
FROM poi p1
WHERE st_dwithin(p1.place,
       (SELECT place FROM poi p2 WHERE p2.graphid = 'http://localhost:7474/db/data/node/145'),
       200
     );

--WHERE DISTANCE((SELECT place FROM poi p2 WHERE p2.graphid = 'http://localhost:7474/db/data/node/145'), p1.place) < 100

--SELECT *
--FROM SPATIAL_REF_SYS
--WHERE srid = 4269 OR srid = 4326 OR srid = 32661

