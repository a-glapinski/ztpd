-- Zad. 1
-- a.
create table FIGURY (
    ID number(1),
    KSZTALT MDSYS.SDO_GEOMETRY
);

-- b.
insert into FIGURY
values (
    1, 
    MDSYS.SDO_GEOMETRY(
        2003, 
        null, 
        null, 
        MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,4),
        MDSYS.SDO_ORDINATE_ARRAY(3,5, 5,3, 7,5)
    )
);
insert into FIGURY
values (
    2, 
    MDSYS.SDO_GEOMETRY(
        2003, 
        null, 
        null, 
        MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,3),
        MDSYS.SDO_ORDINATE_ARRAY(1,1, 5,5)
    )
);
insert into FIGURY
values (
    3, 
    MDSYS.SDO_GEOMETRY(
        2002, 
        null, 
        null, 
        MDSYS.SDO_ELEM_INFO_ARRAY(1,4,2, 1,2,1, 5,2,2),
        MDSYS.SDO_ORDINATE_ARRAY(3,2, 6,2, 7,3, 8,2, 7,1)
    )
);

-- c. 
insert into FIGURY
values (
    4, 
    MDSYS.SDO_GEOMETRY(
        2003, 
        null, 
        null, 
        MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,3),
        MDSYS.SDO_ORDINATE_ARRAY(1,1)
    )
);

-- d.
select ID,
SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(KSZTALT, 0.01) VALID
from FIGURY;

-- e.
delete from FIGURY
where SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(KSZTALT, 0.01) <> 'TRUE';

-- f. 
commit;
