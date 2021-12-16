-- Zad. 1.
-- A.
select lpad('-', 2 * (level - 1), '|-') || t.owner || '.' || t.type_name || ' (FINAL:' || t.final ||
       ', INSTANTIABLE:' || t.instantiable || ', ATTRIBUTES:' || t.attributes || ', METHODS:' || t.methods || ')'
from all_types t
start with t.type_name = 'ST_GEOMETRY'
connect by prior t.type_name = t.supertype_name
       and prior t.owner = t.owner;

-- B.
select distinct m.method_name
from all_type_methods m
where m.type_name like 'ST_POLYGON'
  and m.owner = 'MDSYS'
order by 1;

-- C.
create table MYST_MAJOR_CITIES
(
    FIPS_CNTRY VARCHAR2(2),
    CITY_NAME  VARCHAR2(40),
    STGEOM     ST_POINT
);

-- D.
insert into MYST_MAJOR_CITIES(FIPS_CNTRY, CITY_NAME, STGEOM)
select FIPS_CNTRY, CITY_NAME, treat(ST_POINT.FROM_SDO_GEOM(GEOM) as ST_POINT)
from MAJOR_CITIES;

-- Zad. 2.
-- A.
insert into MYST_MAJOR_CITIES
values ('PL',
        'Szczyrk',
        treat(
                ST_POINT.FROM_WKT('POINT(19.036107 49.718655)') as ST_POINT
            ));

-- B.
select R.NAME, R.GEOM.GET_WKT() AS WKT
from RIVERS R;

-- C.
select SDO_UTIL.TO_GMLGEOMETRY(ST_POINT.GET_SDO_GEOM(STGEOM)) GML
from MYST_MAJOR_CITIES
where CITY_NAME = 'Szczyrk';

-- Zad. 3.
-- A.
create table MYST_COUNTRY_BOUNDARIES
(
    FIPS_CNTRY VARCHAR2(2),
    CNTRY_NAME VARCHAR2(40),
    STGEOM     ST_MULTIPOLYGON
);

-- B.
insert into MYST_COUNTRY_BOUNDARIES(FIPS_CNTRY, CNTRY_NAME, STGEOM)
select FIPS_CNTRY, CNTRY_NAME, ST_MULTIPOLYGON(GEOM)
from COUNTRY_BOUNDARIES;

-- C.
select B.STGEOM.ST_GEOMETRYTYPE() as TYP_OBIEKTU, COUNT(CNTRY_NAME) as ILE
from MYST_COUNTRY_BOUNDARIES B
group by B.STGEOM.ST_GEOMETRYTYPE();

-- D.
select B.STGEOM.ST_ISSIMPLE()
from MYST_COUNTRY_BOUNDARIES B;

-- Zad. 4.
-- A
delete
from MYST_MAJOR_CITIES
where CITY_NAME = 'Szczyrk';
select B.CNTRY_NAME,
       COUNT(*)
from MYST_COUNTRY_BOUNDARIES B,
     MYST_MAJOR_CITIES C
where C.STGEOM.ST_WITHIN(B.STGEOM) = 1
group by B.CNTRY_NAME;

-- B
select B1.CNTRY_NAME A_NAME,
       B2.CNTRY_NAME B_NAME
from MYST_COUNTRY_BOUNDARIES B1,
     MYST_COUNTRY_BOUNDARIES B2
where B1.STGEOM.ST_TOUCHES(B2.STGEOM) = 1
  and B2.CNTRY_NAME = 'Czech Republic';

-- C
select DISTINCT B.CNTRY_NAME,
                R.NAME
from MYST_COUNTRY_BOUNDARIES B,
     RIVERS R
where ST_LINESTRING(R.GEOM).ST_INTERSECTS(B.STGEOM) = 1
  and B.CNTRY_NAME = 'Czech Republic';

-- D
select TREAT(B1.STGEOM.ST_UNION(B2.STGEOM) as ST_POLYGON).ST_Area() POWIERZCHNIA
from MYST_COUNTRY_BOUNDARIES B1,
     MYST_COUNTRY_BOUNDARIES B2
where B1.CNTRY_NAME = 'Czech Republic'
  and B2.CNTRY_NAME = 'Slovakia';

-- E
select B.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(W.GEOM)).ST_GEOMETRYTYPE() as WEGRY_BEZ
from MYST_COUNTRY_BOUNDARIES B,
     WATER_BODIES W
where B.CNTRY_NAME = 'Hungary'
  and W.name = 'Balaton';

-- Zad. 5.
-- A
select COUNT(*)
from MYST_COUNTRY_BOUNDARIES B,
     MYST_MAJOR_CITIES C
where SDO_WITHIN_DISTANCE(B.STGEOM, C.STGEOM, 'distance=100 unit=km') = 'TRUE'
  and B.CNTRY_NAME = 'Poland'
group by B.CNTRY_NAME;

-- B
insert into USER_SDO_GEOM_METADATA
values ('MYST_COUNTRY_BOUNDARIES',
        'STGEOM',
        MDSYS.SDO_DIM_ARRAY(
                MDSYS.SDO_DIM_ELEMENT('X', 19.036107, 21.001011, 0.01),
                MDSYS.SDO_DIM_ELEMENT('Y', 50.28437, 52.079731, 0.01)
            ),
        8307);

-- C
create index MYST_COUNTRY_BOUNDARIES_IDX
    ON MYST_COUNTRY_BOUNDARIES (STGEOM) indextype
    IS MDSYS.SPATIAL_INDEX;

-- D
EXPLAIN PLAN FOR
select B.CNTRY_NAME A_NAME,
       count(*)
from MYST_COUNTRY_BOUNDARIES B,
     MYST_MAJOR_CITIES C
where SDO_WITHIN_DISTANCE(C.STGEOM, B.STGEOM, 'distance=100 unit=km') = 'TRUE'
  and B.CNTRY_NAME = 'Poland'
group by B.CNTRY_NAME;


SELECT plan_table_output
FROM table (dbms_xplan.display('plan_table', null, 'basic'));
