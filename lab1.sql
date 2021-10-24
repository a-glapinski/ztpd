-- Zad. 1
CREATE OR REPLACE TYPE Samochod AS OBJECT
(
    MARKA          VARCHAR2(20),
    MODEL          VARCHAR2(20),
    KILOMETRY      NUMBER,
    DATA_PRODUKCJI DATE,
    CENA           NUMBER(10, 2)
);

DESC Samochod;

CREATE TABLE Samochody OF Samochod;

insert into samochody
values (new Samochod('FIAT', 'BRAVA', 60000, '1999-11-30', 25000));

insert into samochody
values (new Samochod('FORD', 'MONDEO', 80000, '1997-05-10', 45000));

insert into samochody
values (new Samochod('MAZDA', '323', 12000, '2000-09-22', 52000));

select *
from samochody;

-- Zad. 2
CREATE TABLE WLASCICIELE
(
    IMIE     VARCHAR2(100),
    NAZWISKO VARCHAR2(100),
    AUTO     Samochod
);

desc wlasciciele;

insert into wlasciciele
values ('JAN', 'KOWALSKI', new Samochod('FIAT', 'BRAVA', 60000, '1999-11-30', 25000));

select *
from wlasciciele;

-- Zad. 3
ALTER TYPE Samochod REPLACE AS OBJECT (
    MARKA VARCHAR2(20),
    MODEL VARCHAR2(20),
    KILOMETRY NUMBER,
    DATA_PRODUKCJI DATE,
    CENA NUMBER(10, 2),
    MEMBER FUNCTION wartosc RETURN NUMBER
    );

CREATE OR REPLACE TYPE BODY Samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN CENA * POWER(0.9, floor(months_between(sysdate, DATA_PRODUKCJI) / 12));
    END wartosc;
END;

SELECT s.marka, s.cena, s.wartosc()
FROM SAMOCHODY s;

-- Zad. 4
ALTER TYPE Samochod ADD MAP MEMBER FUNCTION odwzoruj
    RETURN NUMBER CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY Samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN CENA * POWER(0.9, floor(months_between(sysdate, DATA_PRODUKCJI) / 12));
    END wartosc;

    MAP MEMBER FUNCTION odwzoruj RETURN NUMBER IS
    BEGIN
        RETURN floor(KILOMETRY / 10000 + floor(months_between(sysdate, DATA_PRODUKCJI) / 12));
    END odwzoruj;
END;

SELECT *
FROM SAMOCHODY s
ORDER BY VALUE(s);

-- Zad. 5
CREATE OR REPLACE TYPE Wlasciciel AS OBJECT
(
    IMIE     VARCHAR2(20),
    NAZWISKO VARCHAR2(20)
);

ALTER TYPE Samochod ADD ATTRIBUTE posiadacz REF Wlasciciel CASCADE;

CREATE TABLE WLASCICIELE_OBJ OF Wlasciciel;

INSERT INTO WLASCICIELE_OBJ
VALUES (NEW Wlasciciel('JAN', 'KOWALSKI'));

INSERT INTO WLASCICIELE_OBJ
VALUES (NEW Wlasciciel('PIOTR', 'NOWAK'));

INSERT INTO WLASCICIELE_OBJ
VALUES (NEW Wlasciciel('TOMASZ', 'NOWAK'));

UPDATE SAMOCHODY
SET POSIADACZ = (
    SELECT REF(w)
    FROM WLASCICIELE_OBJ w
    WHERE w.nazwisko = 'KOWALSKI'
);

-- Zad. 6
DECLARE
    TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
    moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN
    moje_przedmioty(1) := 'MATEMATYKA';
    moje_przedmioty.EXTEND(9);
    FOR i IN 2..10
        LOOP
            moje_przedmioty(i) := 'PRZEDMIOT_' || i;
        END LOOP;
    FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST()
        LOOP
            DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
        END LOOP;
    moje_przedmioty.TRIM(2);
    FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST()
        LOOP
            DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
        END LOOP;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
    moje_przedmioty.EXTEND();
    moje_przedmioty(9) := 9;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
    moje_przedmioty.DELETE();
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
END;

-- Zad. 7
DECLARE
    TYPE t_ksiazki IS VARRAY(10) OF VARCHAR2(20);
    moje_ksiazki t_ksiazki := t_ksiazki('');
BEGIN
    moje_ksiazki(1) := 'GRA O TRON';
    moje_ksiazki.EXTEND(9);

    FOR i IN 2..10
        LOOP
            moje_ksiazki(i) := 'KSIAZKA' || i;
        END LOOP;

    FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST()
        LOOP
            DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
        END LOOP;

    moje_ksiazki.TRIM(2);

    FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST()
        LOOP
            DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
        END LOOP;

    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());

    moje_ksiazki.EXTEND();
    moje_ksiazki(9) := 'Harry Potter';

    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());

    moje_ksiazki.DELETE();

    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());
END;

-- Zad. 8
DECLARE
    TYPE t_wykladowcy IS TABLE OF VARCHAR2(20);
    moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN
    moi_wykladowcy.EXTEND(2);
    moi_wykladowcy(1) := 'MORZY';
    moi_wykladowcy(2) := 'WOJCIECHOWSKI';
    moi_wykladowcy.EXTEND(8);
    FOR i IN 3..10
        LOOP
            moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
        END LOOP;
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST()
        LOOP
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END LOOP;
    moi_wykladowcy.TRIM(2);
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST()
        LOOP
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END LOOP;
    moi_wykladowcy.DELETE(5, 7);
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST()
        LOOP
            IF moi_wykladowcy.EXISTS(i) THEN
                DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
            END IF;
        END LOOP;
    moi_wykladowcy(5) := 'ZAKRZEWICZ';
    moi_wykladowcy(6) := 'KROLIKOWSKI';
    moi_wykladowcy(7) := 'KOSZLAJDA';
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST()
        LOOP
            IF moi_wykladowcy.EXISTS(i) THEN
                DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
            END IF;
        END LOOP;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
END;

-- Zad. 9
DECLARE
    TYPE t_miesiace IS TABLE OF VARCHAR2(20);
    moje_miesiace t_miesiace := t_miesiace();
BEGIN
    moje_miesiace.EXTEND(12);

    moje_miesiace(1) := 'STYCZEN';
    moje_miesiace(2) := 'LUTY';
    moje_miesiace(3) := 'MARZEC';
    moje_miesiace(4) := 'KWIECIEN';
    moje_miesiace(5) := 'MAJ';
    moje_miesiace(6) := 'CZERWIEC';
    moje_miesiace(7) := 'LIPIEC';
    moje_miesiace(8) := 'SIERPIEN';
    moje_miesiace(9) := 'WRZESIEN';
    moje_miesiace(10) := 'PAZDZIERNIK';
    moje_miesiace(11) := 'LISTOPAD';
    moje_miesiace(12) := 'GRUDZIEN';

    FOR i IN moje_miesiace.FIRST()..moje_miesiace.LAST()
        LOOP
            DBMS_OUTPUT.PUT_LINE(moje_miesiace(i));
        END LOOP;

    moje_miesiace.TRIM(2);

    FOR i IN moje_miesiace.FIRST()..moje_miesiace.LAST()
        LOOP
            DBMS_OUTPUT.PUT_LINE(moje_miesiace(i));
        END LOOP;

    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_miesiace.COUNT());

    moje_miesiace.DELETE(3, 5);

    FOR i IN moje_miesiace.FIRST()..moje_miesiace.LAST()
        LOOP
            IF moje_miesiace.EXISTS(i) THEN
                DBMS_OUTPUT.PUT_LINE(moje_miesiace(i));
            END IF;
        END LOOP;

    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_miesiace.COUNT());
END;

-- Zad. 10
CREATE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);
/

CREATE TYPE stypendium AS OBJECT
(
    nazwa  VARCHAR2(50),
    kraj   VARCHAR2(30),
    jezyki jezyki_obce
);
/

CREATE TABLE stypendia OF stypendium;

INSERT INTO stypendia
VALUES ('SOKRATES', 'FRANCJA', jezyki_obce('ANGIELSKI', 'FRANCUSKI', 'NIEMIECKI'));
INSERT INTO stypendia
VALUES ('ERASMUS', 'NIEMCY', jezyki_obce('ANGIELSKI', 'NIEMIECKI', 'HISZPANSKI'));

SELECT *
FROM stypendia;

SELECT s.jezyki
FROM stypendia s;

UPDATE STYPENDIA
SET jezyki = jezyki_obce('ANGIELSKI', 'NIEMIECKI', 'HISZPANSKI', 'FRANCUSKI')
WHERE nazwa = 'ERASMUS';

CREATE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);
/

CREATE TYPE semestr AS OBJECT
(
    numer    NUMBER,
    egzaminy lista_egzaminow
);
/

CREATE TABLE semestry OF semestr
    NESTED TABLE egzaminy STORE AS tab_egzaminy;

INSERT INTO semestry
VALUES (semestr(1, lista_egzaminow('MATEMATYKA', 'LOGIKA', 'ALGEBRA')));
INSERT INTO semestry
VALUES (semestr(2, lista_egzaminow('BAZY DANYCH', 'SYSTEMY OPERACYJNE')));

SELECT s.numer, e.*
FROM semestry s,
     TABLE (s.egzaminy) e;

SELECT e.*
FROM semestry s,
     TABLE ( s.egzaminy ) e;

SELECT *
FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer = 1 );

INSERT INTO TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer = 2 )
VALUES ('METODY NUMERYCZNE');

UPDATE TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer = 2 ) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';

DELETE
FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer = 2 ) e
WHERE e.column_value = 'BAZY DANYCH';

-- Zad. 11
CREATE TYPE produkty AS TABLE OF VARCHAR2(20);

CREATE TYPE zakup AS OBJECT
(
    id               NUMBER,
    koszyk_produktow produkty
);

CREATE TABLE zakupy OF zakup
    NESTED TABLE koszyk_produktow STORE AS tab_koszyk_produktow;

INSERT INTO zakupy
VALUES (zakup(1, produkty('SER', 'KAWA', 'WODA')));
INSERT INTO zakupy
VALUES (zakup(2, produkty('SOK', 'HERBATA')));
INSERT INTO zakupy
VALUES (zakup(3, produkty('JOGURT', 'JABLKO')));

SELECT s.*, e.*
FROM zakupy s,
     TABLE (s.koszyk_produktow) e;

SELECT e.*
FROM zakupy s,
     TABLE ( s.koszyk_produktow ) e;

DELETE
FROM zakupy s
where s.id IN (
    SELECT z.id
    FROM zakupy z,
         TABLE (z.koszyk_produktow) p
    WHERE p.column_value = 'SOK'
);

-- Zad. 12
CREATE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);
/

CREATE TYPE stypendium AS OBJECT
(
    nazwa  VARCHAR2(50),
    kraj   VARCHAR2(30),
    jezyki jezyki_obce
);
/

CREATE TABLE stypendia OF stypendium;

INSERT INTO stypendia
VALUES ('SOKRATES', 'FRANCJA', jezyki_obce('ANGIELSKI', 'FRANCUSKI', 'NIEMIECKI'));

INSERT INTO stypendia
VALUES ('ERASMUS', 'NIEMCY', jezyki_obce('ANGIELSKI', 'NIEMIECKI', 'HISZPANSKI'));

SELECT *
FROM stypendia;

SELECT s.jezyki
FROM stypendia s;

UPDATE STYPENDIA
SET jezyki = jezyki_obce('ANGIELSKI', 'NIEMIECKI', 'HISZPANSKI', 'FRANCUSKI')
WHERE nazwa = 'ERASMUS';

CREATE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);
/

CREATE TYPE semestr AS OBJECT
(
    numer    NUMBER,
    egzaminy lista_egzaminow
);
/

CREATE TABLE semestry OF semestr
    NESTED TABLE egzaminy STORE AS tab_egzaminy;

INSERT INTO semestry
VALUES (semestr(1, lista_egzaminow('MATEMATYKA', 'LOGIKA', 'ALGEBRA')));
INSERT INTO semestry
VALUES (semestr(2, lista_egzaminow('BAZY DANYCH', 'SYSTEMY OPERACYJNE')));

SELECT s.numer, e.*
FROM semestry s,
     TABLE (s.egzaminy) e;

SELECT e.*
FROM semestry s,
     TABLE ( s.egzaminy ) e;

SELECT *
FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer = 1 );

INSERT INTO TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer = 2 )
VALUES ('METODY NUMERYCZNE');

UPDATE TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer = 2 ) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';

DELETE
FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer = 2 ) e
WHERE e.column_value = 'BAZY DANYCH';

-- Zad. 13
CREATE TYPE istota AS OBJECT
(
    nazwa VARCHAR2(20),
    NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR
)
    NOT INSTANTIABLE NOT FINAL;

CREATE TYPE lew UNDER istota
(
    liczba_nog NUMBER,
    OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR
);

CREATE OR REPLACE TYPE BODY lew AS
    OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
    BEGIN
        RETURN 'upolowana ofiara: ' || ofiara;
    END;
END;

DECLARE
    KrolLew lew := lew('LEW', 4);
BEGIN
    DBMS_OUTPUT.PUT_LINE(KrolLew.poluj('antylopa'));
END;

-- Zad. 14
DECLARE
    tamburyn instrument;
    cymbalki instrument;
    trabka   instrument_dety;
    saksofon instrument_dety;
BEGIN
    tamburyn := instrument('tamburyn', 'brzdek-brzdek');
    cymbalki := instrument_dety('cymbalki', 'ding-ding', 'metalowe');
    trabka := instrument_dety('trabka', 'tra-ta-ta', 'metalowa');
    -- saksofon := instrument('saksofon','tra-taaaa');
    -- saksofon := TREAT(instrument('saksofon','tra-taaaa') AS instrument_dety);
END;

-- Zad. 15
CREATE TABLE instrumenty OF instrument;

INSERT INTO instrumenty
VALUES (instrument('tamburyn', 'brzdek-brzdek'));
INSERT INTO instrumenty
VALUES (instrument_dety('trabka', 'tra-ta-ta', 'metalowa'));
INSERT INTO instrumenty
VALUES (instrument_klawiszowy('fortepian', 'pingping', 'steinway'));

SELECT i.nazwa, i.graj()
FROM instrumenty i;

-- Zad. 16
CREATE TABLE PRZEDMIOTY
(
    NAZWA      VARCHAR2(50),
    NAUCZYCIEL NUMBER REFERENCES PRACOWNICY (ID_PRAC)
);

INSERT INTO PRZEDMIOTY VALUES ('BAZY DANYCH',100);
INSERT INTO PRZEDMIOTY VALUES ('SYSTEMY OPERACYJNE',100);
INSERT INTO PRZEDMIOTY VALUES ('PROGRAMOWANIE',110);
INSERT INTO PRZEDMIOTY VALUES ('SIECI KOMPUTEROWE',110);
INSERT INTO PRZEDMIOTY VALUES ('BADANIA OPERACYJNE',120);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',120);
INSERT INTO PRZEDMIOTY VALUES ('BAZY DANYCH',130);
INSERT INTO PRZEDMIOTY VALUES ('SYSTEMY OPERACYJNE',140);
INSERT INTO PRZEDMIOTY VALUES ('PROGRAMOWANIE',140);
INSERT INTO PRZEDMIOTY VALUES ('SIECI KOMPUTEROWE',140);
INSERT INTO PRZEDMIOTY VALUES ('BADANIA OPERACYJNE',150);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',150);
INSERT INTO PRZEDMIOTY VALUES ('BAZY DANYCH',160);
INSERT INTO PRZEDMIOTY VALUES ('SYSTEMY OPERACYJNE',160);
INSERT INTO PRZEDMIOTY VALUES ('PROGRAMOWANIE',170);
INSERT INTO PRZEDMIOTY VALUES ('SIECI KOMPUTEROWE',180);
INSERT INTO PRZEDMIOTY VALUES ('BADANIA OPERACYJNE',180);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',190);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',200);
INSERT INTO PRZEDMIOTY VALUES ('GRAFIKA KOMPUTEROWA',210);
INSERT INTO PRZEDMIOTY VALUES ('PROGRAMOWANIE',220);
INSERT INTO PRZEDMIOTY VALUES ('SIECI KOMPUTEROWE',220);
INSERT INTO PRZEDMIOTY VALUES ('BADANIA OPERACYJNE',230);

-- Zad. 17
CREATE TYPE ZESPOL AS OBJECT
(
    ID_ZESP NUMBER,
    NAZWA   VARCHAR2(50),
    ADRES   VARCHAR2(100)
);
/

-- Zad. 18
CREATE OR REPLACE VIEW ZESPOLY_V
            OF ZESPOL
                WITH OBJECT IDENTIFIER (ID_ZESP)
AS
SELECT ID_ZESP, NAZWA, ADRES
FROM ZESPOLY;

-- Zad. 19
CREATE TYPE PRZEDMIOTY_TAB AS TABLE OF VARCHAR2(100);
/

CREATE TYPE PRACOWNIK AS OBJECT
(
    ID_PRAC       NUMBER,
    NAZWISKO      VARCHAR2(30),
    ETAT          VARCHAR2(20),
    ZATRUDNIONY   DATE,
    PLACA_POD     NUMBER(10, 2),
    MIEJSCE_PRACY REF ZESPOL,
    PRZEDMIOTY    PRZEDMIOTY_TAB,
    MEMBER FUNCTION ILE_PRZEDMIOTOW RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY PRACOWNIK AS
    MEMBER FUNCTION ILE_PRZEDMIOTOW RETURN NUMBER IS
    BEGIN
        RETURN PRZEDMIOTY.COUNT();
    END ILE_PRZEDMIOTOW;
END;

-- Zad. 20
CREATE OR REPLACE VIEW PRACOWNICY_V
            OF PRACOWNIK
                WITH OBJECT IDENTIFIER (ID_PRAC)
AS
SELECT ID_PRAC,
       NAZWISKO,
       ETAT,
       ZATRUDNIONY,
       PLACA_POD,
       MAKE_REF(ZESPOLY_V, ID_ZESP),
       CAST(MULTISET(SELECT NAZWA FROM PRZEDMIOTY WHERE NAUCZYCIEL = P.ID_PRAC) AS PRZEDMIOTY_TAB)
FROM PRACOWNICY P;

-- Zad. 21
SELECT *
FROM PRACOWNICY_V;

SELECT P.NAZWISKO, P.ETAT, P.MIEJSCE_PRACY.NAZWA
FROM PRACOWNICY_V P;

SELECT P.NAZWISKO, P.ILE_PRZEDMIOTOW()
FROM PRACOWNICY_V P;

SELECT *
FROM TABLE ( SELECT PRZEDMIOTY FROM PRACOWNICY_V WHERE NAZWISKO = 'WEGLARZ');

SELECT NAZWISKO, CURSOR (SELECT PRZEDMIOTY FROM PRACOWNICY_V WHERE ID_PRAC = P.ID_PRAC)
FROM PRACOWNICY_V P;

-- Zad. 22
CREATE TABLE PISARZE
(
    ID_PISARZA NUMBER PRIMARY KEY,
    NAZWISKO   VARCHAR2(20),
    DATA_UR    DATE
);

CREATE TABLE KSIAZKI
(
    ID_KSIAZKI   NUMBER PRIMARY KEY,
    ID_PISARZA   NUMBER NOT NULL REFERENCES PISARZE,
    TYTUL        VARCHAR2(50),
    DATA_WYDANIA DATE
);

INSERT INTO PISARZE
VALUES (10, 'SIENKIEWICZ', DATE '1880-01-01');
INSERT INTO PISARZE
VALUES (20, 'PRUS', DATE '1890-04-12');
INSERT INTO PISARZE
VALUES (30, 'ZEROMSKI', DATE '1899-09-11');

INSERT INTO KSIAZKI(ID_KSIAZKI, ID_PISARZA, TYTUL, DATA_WYDANIA)
VALUES (10, 10, 'OGNIEM I MIECZEM', DATE '1990-01-05');
INSERT INTO KSIAZKI(ID_KSIAZKI, ID_PISARZA, TYTUL, DATA_WYDANIA)
VALUES (20, 10, 'POTOP', DATE '1975-12-09');
INSERT INTO KSIAZKI(ID_KSIAZKI, ID_PISARZA, TYTUL, DATA_WYDANIA)
VALUES (30, 10, 'PAN WOLODYJOWSKI', DATE '1987-02-15');
INSERT INTO KSIAZKI(ID_KSIAZKI, ID_PISARZA, TYTUL, DATA_WYDANIA)
VALUES (40, 20, 'FARAON', DATE '1948-01-21');
INSERT INTO KSIAZKI(ID_KSIAZKI, ID_PISARZA, TYTUL, DATA_WYDANIA)
VALUES (50, 20, 'LALKA', DATE '1994-08-01');
INSERT INTO KSIAZKI(ID_KSIAZKI, ID_PISARZA, TYTUL, DATA_WYDANIA)
VALUES (60, 30, 'PRZEDWIOSNIE', DATE '1938-02-02');

CREATE TYPE KSIAZKI_TAB AS TABLE OF VARCHAR2(100);

CREATE TYPE PISARZ AS OBJECT
(
    ID_PISARZA NUMBER,
    NAZWISKO   VARCHAR2(20),
    DATA_UR    DATE,
    KSIAZKI    KSIAZKI_TAB,
    MEMBER FUNCTION ILE_KSIAZEK RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY PISARZ AS
    MEMBER FUNCTION ILE_KSIAZEK RETURN NUMBER IS
    BEGIN
        RETURN KSIAZKI.COUNT();
    END ILE_KSIAZEK;
END;

CREATE TYPE KSIAZKA AS OBJECT
(
    ID_KSIAZKI   NUMBER,
    AUTOR        REF PISARZ,
    TYTUL        VARCHAR2(50),
    DATA_WYDANIA DATE,
    MEMBER FUNCTION WIEK RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY KSIAZKA AS
    MEMBER FUNCTION WIEK RETURN NUMBER IS
    BEGIN
        RETURN EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM DATA_WYDANIA);
    END WIEK;
END;

CREATE OR REPLACE VIEW PISARZE_V
            OF PISARZ
                WITH OBJECT IDENTIFIER (ID_PISARZA)
AS
SELECT ID_PISARZA,
       NAZWISKO,
       DATA_UR,
       CAST(MULTISET(SELECT TYTUL FROM KSIAZKI WHERE ID_PISARZA = P.ID_PISARZA) AS KSIAZKI_TAB)
FROM PISARZE P;

CREATE OR REPLACE VIEW KSIAZKI_V
            OF KSIAZKA
                WITH OBJECT IDENTIFIER (ID_KSIAZKI)
AS
SELECT ID_KSIAZKI, MAKE_REF(PISARZE_V, ID_PISARZA), TYTUL, DATA_WYDANIA
FROM KSIAZKI;

SELECT *
FROM PISARZE_V;

SELECT K.DATA_WYDANIA, K.TYTUL, K.WIEK()
FROM KSIAZKI_V K;

SELECT P.NAZWISKO, P.ILE_KSIAZEK()
FROM PISARZE_V P;

SELECT P.NAZWISKO, K.*
FROM PISARZE_V P,
     TABLE (P.KSIAZKI) K;

-- Zad. 23
CREATE TYPE AUTO AS OBJECT
(
    MARKA          VARCHAR2(20),
    MODEL          VARCHAR2(20),
    KILOMETRY      NUMBER,
    DATA_PRODUKCJI DATE,
    CENA           NUMBER(10, 2),
    MEMBER FUNCTION WARTOSC RETURN NUMBER
) NOT FINAL;

CREATE OR REPLACE TYPE BODY AUTO AS
    MEMBER FUNCTION WARTOSC RETURN NUMBER IS
        WIEK    NUMBER;
        WARTOSC NUMBER;
    BEGIN
        WIEK := ROUND(MONTHS_BETWEEN(SYSDATE, DATA_PRODUKCJI) / 12);
        WARTOSC := CENA - (WIEK * 0.1 * CENA);
        IF (WARTOSC < 0) THEN
            WARTOSC := 0;
        END IF;
        RETURN WARTOSC;
    END WARTOSC;
END;

CREATE TYPE AUTO_OSOBOWE UNDER AUTO
(
    LICZBA_MIEJSC    NUMBER,
    CZY_KLIMATYZACJA VARCHAR2(3),
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY AUTO_OSOBOWE AS
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER IS
        WARTOSC NUMBER;
    BEGIN
        WARTOSC := (SELF AS AUTO).WARTOSC();
        IF (CZY_KLIMATYZACJA = 'TAK') THEN
            WARTOSC := WARTOSC * 1.5;
        END IF;
        RETURN WARTOSC;
    END;
END;

CREATE TYPE AUTO_CIEZAROWE UNDER AUTO
(
    MAKSYMALNA_LADOWNOSC NUMBER,
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY AUTO_CIEZAROWE AS
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER IS
        WARTOSC NUMBER;
    BEGIN
        WARTOSC := (SELF AS AUTO).WARTOSC();
        IF (MAKSYMALNA_LADOWNOSC > 10000) THEN
            WARTOSC := WARTOSC * 2;
        END IF;
        RETURN WARTOSC;
    END;
END;

CREATE TABLE AUTA OF AUTO;

INSERT INTO AUTA
VALUES (AUTO('FIAT', 'BRAVA', 60000, DATE '2020-11-30', 25000));
INSERT INTO AUTA
VALUES (AUTO('FORD', 'MONDEO', 80000, DATE '2020-05-10', 45000));
INSERT INTO AUTA
VALUES (AUTO('MAZDA', '323', 12000, DATE '2020-09-22', 52000));

INSERT INTO AUTA
VALUES (AUTO_OSOBOWE('SKODA', 'FABIA', 20000, DATE '2020-11-30', 25000, 5, 'TAK'));
INSERT INTO AUTA
VALUES (AUTO_OSOBOWE('FORD', 'FIESTA', 40000, DATE '2020-11-30', 45000, 4, 'NIE'));
INSERT INTO AUTA
VALUES (AUTO_CIEZAROWE('VOLVO', 'FH4', 80000, DATE '2020-11-30', 50000, 8000));
INSERT INTO AUTA
VALUES (AUTO_CIEZAROWE('MAN', 'TGE', 120000, DATE '2020-11-30', 50000, 12000));

SELECT A.MARKA, A.WARTOSC()
FROM AUTA A;

SELECT A.*, A.WARTOSC()
FROM AUTA A;
