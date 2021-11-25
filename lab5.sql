-- Zad. 1.
-- A.
INSERT INTO USER_SDO_GEOM_METADATA
VALUES ('FIGURY',
        'KSZTALT',
        MDSYS.SDO_DIM_ARRAY(
                MDSYS.SDO_DIM_ELEMENT('X', 0, 9, 0.01),
                MDSYS.SDO_DIM_ELEMENT('Y', 0, 9, 0.01)),
        NULL);

-- B.
select SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000, 8192, 10, 2, 0)
from dual;

-- C.
CREATE INDEX figura_spatial_idx
    ON figury (ksztalt)
    INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

-- D.
select ID
from FIGURY
where SDO_FILTER(KSZTALT,
                 SDO_GEOMETRY(2001, null,
                              SDO_POINT_TYPE(3, 3, null),
                              null, null)) = 'TRUE';

-- E.
select ID
from FIGURY
where SDO_RELATE(KSZTALT,
                 SDO_GEOMETRY(2001, null,
                              SDO_POINT_TYPE(3, 3, null),
                              null, null),
                 'mask=ANYINTERACT') = 'TRUE';

-- Zad. 2.
-- A.
select MC.CITY_NAME MIASTO, ROUND(SDO_NN_DISTANCE(1), 8) ODL
from MAJOR_CITIES MC
where SDO_NN(GEOM,
             (select geom from major_cities where city_name = 'Warsaw'),
             'sdo_num_res=10 unit=km', 1) = 'TRUE'
  and mc.city_name <> 'Warsaw';

-- B.
select C.CITY_NAME
from MAJOR_CITIES C
where SDO_WITHIN_DISTANCE(C.GEOM,
                          (select geom from major_cities where city_name = 'Warsaw'),
                          'distance=100 unit=km') = 'TRUE'
  and c.city_name <> 'Warsaw';

-- C.
select B.CNTRY_NAME as KRAJ,
       C.CITY_NAME  as MIASTO
from COUNTRY_BOUNDARIES B,
     MAJOR_CITIES C
where SDO_RELATE(C.GEOM, B.GEOM, 'mask=inside') = 'TRUE'
  and B.CNTRY_NAME = 'Slovakia';

-- D.
select A.CNTRY_NAME                                        as PANSTWO,
       SDO_GEOM.SDO_DISTANCE(A.GEOM, B.GEOM, 1, 'unit=km') as ODL
from COUNTRY_BOUNDARIES A,
     COUNTRY_BOUNDARIES B
where SDO_RELATE(A.GEOM, B.GEOM, 'mask=ANYINTERACT') <> 'TRUE'
  and B.CNTRY_NAME = 'Poland';

-- Zad. 3.
-- A.
select A.CNTRY_NAME,
       SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(A.GEOM, B.GEOM, 1), 1, 'unit=km') as ODLEGLOSC
from COUNTRY_BOUNDARIES A,
     COUNTRY_BOUNDARIES B
where SDO_RELATE(A.GEOM, B.GEOM, 'mask=TOUCH') = 'TRUE'
  and B.CNTRY_NAME = 'Poland';

-- B.
select CNTRY_NAME
from COUNTRY_BOUNDARIES
where SDO_GEOM.SDO_AREA(GEOM) = (select MAX(SDO_GEOM.SDO_AREA(GEOM))
                                 from COUNTRY_BOUNDARIES);

-- C.
select SDO_GEOM.SDO_AREA(SDO_GEOM.SDO_MBR(SDO_GEOM.SDO_UNION(A.GEOM, B.GEOM, 0.01)), 1, 'unit=SQ_KM') SQ_KM
from MAJOR_CITIES A,
     MAJOR_CITIES B
where A.CITY_NAME = 'Warsaw'
  and B.CITY_NAME = 'Lodz';

-- D.
select SDO_GEOM.SDO_UNION(A.GEOM, B.GEOM, 0.01).GET_DIMS() ||
       SDO_GEOM.SDO_UNION(A.GEOM, B.GEOM, 0.01).GET_LRS_DIM() ||
       LPAD(SDO_GEOM.SDO_UNION(A.GEOM, B.GEOM, 0.01).GET_GTYPE(), 2, '0') GTYPE
from COUNTRY_BOUNDARIES A,
     MAJOR_CITIES B
where A.CNTRY_NAME = 'Poland'
  and B.CITY_NAME = 'Prague';

-- E.
select B.CITY_NAME,
       A.CNTRY_NAME
from COUNTRY_BOUNDARIES A,
     MAJOR_CITIES B
where A.CNTRY_NAME = B.CNTRY_NAME
  and SDO_GEOM.SDO_DISTANCE(SDO_GEOM.SDO_CENTROID(A.GEOM, 1), B.GEOM, 1) = (
    select MIN(SDO_GEOM.SDO_DISTANCE(SDO_GEOM.SDO_CENTROID(A.GEOM, 1), B.GEOM, 1))
    from COUNTRY_BOUNDARIES A,
         MAJOR_CITIES B
    where A.CNTRY_NAME = B.CNTRY_NAME
);

-- F.
select NAME,
       SUM(DLUGOSC) DLUGOSC
from (select B.NAME,
             SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(A.GEOM, B.GEOM, 1), 1, 'unit=KM') DLUGOSC
      from COUNTRY_BOUNDARIES A,
           RIVERS B
      where SDO_RELATE(A.GEOM, SDO_GEOMETRY(2001, 8307, B.GEOM.SDO_POINT, B.GEOM.SDO_ELEM_INFO, B.GEOM.SDO_ORDINATES),
                       'mask=ANYINTERACT') = 'TRUE'
        and A.CNTRY_NAME = 'Poland')
group by NAME;
