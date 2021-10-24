-- Zad. 1
create table MOVIES
(
    ID        NUMBER(12) PRIMARY KEY,
    TITLE     VARCHAR2(400) NOT NULL,
    CATEGORY  VARCHAR2(50),
    YEAR      CHAR(4),
    CAST      VARCHAR2(4000),
    DIRECTOR  VARCHAR2(4000),
    STORY     VARCHAR2(4000),
    PRICE     NUMBER(5, 2),
    COVER     BLOB,
    MIME_TYPE VARCHAR2(50)
);

-- Zad. 2
insert into movies
select d.id,
       d.title,
       d.category,
       TRIM(d.year),
       d.cast,
       d.director,
       d.story,
       d.price,
       c.image,
       c.mime_type
from descriptions d
         left outer join covers c
                         on d.id = c.movie_id;

-- Zad. 3
select id, title
from movies
where cover is null;

-- Zad. 4
select id, title, dbms_lob.getlength(cover) FILESIZE
from movies
where cover is not null;

-- Zad. 5
select id, title, dbms_lob.getlength(cover) FILESIZE
from movies
where cover is null;

-- Zad. 6
select *
from ALL_DIRECTORIES;

-- Zad. 7
update movies
set cover     = EMPTY_BLOB(),
    mime_type = 'image/jpeg'
where id = 66;

-- Zad. 8
select id, title, dbms_lob.getlength(cover) FILESIZE
from movies
where id in (65, 66);

-- Zad. 9
DECLARE
    lobd blob;
    fils BFILE := BFILENAME('ZSBD_DIR', 'escape.jpg');
BEGIN
    SELECT cover
    INTO lobd
    FROM movies
    WHERE id = 66
        FOR UPDATE;

    DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADFROMFILE(lobd, fils, DBMS_LOB.GETLENGTH(fils));
    DBMS_LOB.FILECLOSE(fils);
    COMMIT;
END;

-- Zad. 10
create table TEMP_COVERS
(
    movie_id  NUMBER(12),
    image     BFILE,
    mime_type VARCHAR2(50)
);

-- Zad. 11
INSERT INTO temp_covers
VALUES (65, BFILENAME('ZSBD_DIR', 'eagles.jpg'), 'image/jpeg');

-- Zad. 12
select movie_id, dbms_lob.getlength(image) FILESIZE
from temp_covers;

-- Zad. 13
DECLARE
    LOBD   blob;
    FILS   BFILE;
    M_TYPE varchar2(50);
BEGIN
    select IMAGE, MIME_TYPE
    into FILS, M_TYPE
    from TEMP_COVERS
    where MOVIE_ID = 65;

    DBMS_LOB.CREATETEMPORARY(LOBD, true, dbms_lob.session);
    DBMS_LOB.FILEOPEN(FILS, dbms_lob.file_readonly);
    DBMS_LOB.LOADFROMFILE(LOBD, FILS, dbms_lob.getlength(FILS));
    DBMS_LOB.FILECLOSE(FILS);

    update MOVIES
    set COVER     = LOBD,
        MIME_TYPE = M_TYPE
    where ID = 65;

    DBMS_LOB.FREETEMPORARY(LOBD);
    COMMIT;
END;

-- Zad. 14
select ID, DBMS_LOB.GETLENGTH(COVER) FILESIZE
from MOVIES
where ID in (65, 66);

-- Zad. 15
drop table MOVIES;
drop table TEMP_COVERS;
