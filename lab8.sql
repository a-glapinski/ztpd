-- Operator CONTAINS - Podstawy
-- 1
create table CYTATY AS
select *
from ZSBD_TOOLS.CYTATY;

-- 2
select AUTOR, TEKST
from CYTATY
where LOWER(TEKST) LIKE '%pesymista%'
  AND LOWER(TEKST) LIKE '%optymista%';

-- 3
create index CYTATY_TEKST_IDX on CYTATY (TEKST)
    indextype is CTXSYS.CONTEXT;

-- 4
select AUTOR,
       TEKST
from CYTATY
where CONTAINS(TEKST, 'PESYMISTA AND OPTYMISTA', 1) > 0;

-- 5
select AUTOR, TEKST
from CYTATY
where CONTAINS(TEKST, 'PESYMISTA ~ OPTYMISTA', 1) > 0;

-- 6
select AUTOR, TEKST
from CYTATY
where CONTAINS(TEKST, 'NEAR((PESYMISTA, OPTYMISTA), 3)') > 0;

-- 7
select AUTOR, TEKST
from CYTATY
where CONTAINS(TEKST, 'NEAR((PESYMISTA, OPTYMISTA), 10)') > 0;

-- 8
select AUTOR, TEKST
from CYTATY
where CONTAINS(TEKST, 'życi%', 1) > 0;

-- 9
select SCORE(1) AS DOPASOWANIE, AUTOR, TEKST
from CYTATY
where CONTAINS(TEKST, 'życi%', 1) > 0;

-- 10
select AUTOR, TEKST, SCORE(1) AS DOPASOWANIE
from CYTATY
where CONTAINS(TEKST, 'życi%', 1) > 0
  and ROWNUM <= 1
ORDER BY DOPASOWANIE DESC;

-- 11
select AUTOR, TEKST
from CYTATY
where CONTAINS(TEKST, 'FUZZY(PROBLEM,,,N)', 1) > 0;

-- 12
-- delete from CYTATY where ID = 39;

insert into CYTATY
values (39,
        'Bertrand Russell',
        'To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.');
COMMIT;

select *
from CYTATY;

-- 13
select AUTOR, TEKST
from CYTATY
where CONTAINS(TEKST, 'GŁUPCY', 1) > 0;
-- nie zaktualizowaliśmy indeksu

-- 14
select TOKEN_TEXT
from DR$CYTATY_TEKST_IDX$I;

select TOKEN_TEXT
from DR$CYTATY_TEKST_IDX$I
where TOKEN_TEXT = 'GŁUPCY';

-- 15
DROP index CYTATY_TEKST_IDX;

create index CYTATY_TEKST_IDX on CYTATY (TEKST)
    indextype is CTXSYS.CONTEXT;

-- 16
select AUTOR, TEKST
from CYTATY
where CONTAINS(TEKST, 'GŁUPCY', 1) > 0;

-- 17
DROP index CYTATY_TEKST_IDX;

DROP table CYTATY;

-- Zaawansowane indeksowanie i wyszukiwanie
-- 1
create table QUOTES AS
select *
from ZSBD_TOOLS.QUOTES;

-- 2
create index QUOTES_TEXT_IDX on QUOTES (TEXT)
    indextype is CTXSYS.CONTEXT;

-- 3
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'WORK', 1) > 0;

select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, '$WORK', 1) > 0;

select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'WORKING', 1) > 0;

select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, '$WORKING', 1) > 0;

-- 4
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'IT', 1) > 0;
-- słowo 'IT' to stop-word i nie znajduje się w indeksie

-- 5
select *
from CTX_STOPLISTS;
-- DEFAULT_STOPLIST

-- 6
select *
from CTX_STOPWORDS;

-- 7
drop index QUOTES_TEXT_IDX;

create index QUOTES_TEXT_IDX on QUOTES (TEXT)
    indextype is CTXSYS.CONTEXT parameters ('
    stoplist CTXSYS.EMPTY_STOPLIST
');

-- 8
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'IT', 1) > 0;
-- tak

-- 9
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'FOOL AND HUMANS', 1) > 0;

-- 10
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'FOOL AND COMPUTER', 1) > 0;

-- 11
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, '(FOOL AND COMPUTER) WITHIN SENTENCE', 1) > 0;
-- nie zdefiniowano sekcji SENTENCE

-- 12
DROP index QUOTES_TEXT_IDX;

-- 13
BEGIN
    ctx_ddl.create_section_group('nullgroup', 'NULL_SECTION_GROUP');
    ctx_ddl.add_special_section('nullgroup', 'SENTENCE');
    ctx_ddl.add_special_section('nullgroup', 'PARAGRAPH');
END;

-- 14
create index QUOTES_TEXT_IDX on QUOTES (TEXT)
    indextype is CTXSYS.CONTEXT parameters ('
    stoplist CTXSYS.EMPTY_STOPLIST
    section group nullgroup
');

-- 15
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, '(FOOL AND HUMANS) WITHIN SENTENCE', 1) > 0;

select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, '(FOOL AND COMPUTER) WITHIN SENTENCE', 1) > 0;

-- 16
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'HUMANS', 1) > 0;
-- zwrócił non-humans
-- bo znak '-' nie jest częścią indeksowanych tokenów

-- 17
DROP index QUOTES_TEXT_IDX;

BEGIN
    ctx_ddl.create_preference('lex_z_m', 'BASIC_LEXER');
    ctx_ddl.set_attribute('lex_z_m', 'printjoins', '_-');
    ctx_ddl.set_attribute('lex_z_m', 'index_text', 'YES');
END;

create index QUOTES_TEXT_IDX on QUOTES (TEXT)
    indextype is CTXSYS.CONTEXT parameters ('
    stoplist CTXSYS.EMPTY_STOPLIST
    section group nullgroup
    LEXER lex_z_m
');

-- 18
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'HUMANS', 1) > 0;
-- nie zwrócił

-- 19
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'NON\-HUMANS', 1) > 0;

-- 20
DROP table QUOTES;

BEGIN
    ctx_ddl.drop_preference('lex_z_m');
END;
