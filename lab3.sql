-- Zad. 1
create table DOKUMENTY
(
    ID       NUMBER(12) PRIMARY KEY,
    DOKUMENT CLOB
);

-- Zad. 2
declare
    dane CLOB;
begin
    for i in 1..10000
        loop
            dane := dane || 'Oto tekst. ';
        end loop;
    insert into dokumenty
    values (1, dane);
    commit;
end;

-- Zad. 3
-- a)
select *
from dokumenty;

-- b)
select upper(dokument)
from dokumenty
where id = 1;

-- c)
select length(dokument)
from dokumenty
where id = 1;

-- d)
select dbms_lob.getlength(dokument) document_size
from dokumenty
where id = 1;

-- e)
select substr(dokument, 5, 1000)
from dokumenty
where id = 1;

-- f)
select dbms_lob.substr(dokument, 1000, 5)
from dokumenty
where id = 1;

-- Zad. 4
insert into dokumenty
values (2, empty_clob());

-- Zad. 5
insert into dokumenty
values (3, null);

-- Zad. 6
-- a)
select *
from dokumenty;

-- b)
select upper(dokument)
from dokumenty;

-- c)
select length(dokument)
from dokumenty;

-- d)
select dbms_lob.getlength(dokument) document_size
from dokumenty;

-- e)
select substr(dokument, 5, 1000)
from dokumenty;

-- f)
select dbms_lob.substr(dokument, 1000, 5)
from dokumenty;

-- Zad. 7
select *
from all_directories;

-- Zad. 8
DECLARE
    lobd    clob;
    fils    BFILE   := BFILENAME('ZSBD_DIR', 'dokument.txt');
    doffset integer := 1;
    soffset integer := 1;
    langctx integer := 0;
    warn    integer := null;
BEGIN
    select dokument
    into lobd
    from dokumenty
    where id = 2
        for update;

    DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADCLOBFROMFILE(lobd, fils, DBMS_LOB.LOBMAXSIZE, doffset, soffset, 873, langctx, warn); -- 873 to utf-8
    DBMS_LOB.FILECLOSE(fils);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Status operacji: ' || warn);
END;

-- Zad. 9
update dokumenty
set dokument = to_clob(bfilename('ZSBD_DIR', 'dokument.txt'))
where id = 3;

-- Zad. 10
select *
from dokumenty;

-- Zad. 11
select id, dbms_lob.getlength(dokument) document_size
from dokumenty;

-- Zad. 12
drop table dokumenty;

-- Zad. 13
create or replace procedure CLOB_CENSOR(IN_CLOB IN CLOB, STR_TO_REPLACE IN VARCHAR2, OUT_CLOB OUT CLOB)
    is
    POS      INTEGER;
    CENSORED VARCHAR2(255);
begin
    select rpad('.', length(STR_TO_REPLACE), '.')
    into CENSORED
    from dual;

    OUT_CLOB := IN_CLOB;
    POS := DBMS_LOB.INSTR(OUT_CLOB, STR_TO_REPLACE);
    while POS <> 0
        loop
            DBMS_LOB.WRITE(OUT_CLOB, length(STR_TO_REPLACE), POS, CENSORED);
            POS := DBMS_LOB.INSTR(OUT_CLOB, STR_TO_REPLACE);
        end loop;
end CLOB_CENSOR;

-- Zad. 14
create table BIOGRAPHIES_COPY as
select *
from ZSBD_TOOLS.BIOGRAPHIES;

declare
    in_clob  CLOB;
    out_clob CLOB;
begin
    select b_c.BIO
    into in_clob
    from BIOGRAPHIES_COPY b_c
        for update;

    CLOB_CENSOR(in_clob, 'Cimrman', out_clob);

    commit;
end;

select *
from BIOGRAPHIES_COPY;

-- Zad. 15
drop table BIOGRAPHIES_COPY;
