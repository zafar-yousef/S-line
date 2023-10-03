-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S5: Subqueries
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
--
--
-- Opdracht: schrijf SQL-queries om onderstaande resultaten op te vragen,
-- aan te maken, verwijderen of aan te passen in de database van de
-- bedrijfscasus.
--
-- NB: Gebruik in elke vraag van deze opdracht een subquery.
--
-- Codeer je uitwerking onder de regel 'DROP VIEW ...' (bij een SELECT)
-- of boven de regel 'ON CONFLICT DO NOTHING;' (bij een INSERT)
-- Je kunt deze eigen query selecteren en los uitvoeren, en wijzigen tot
-- je tevreden bent.

-- Vervolgens kun je je uitwerkingen testen door de testregels
-- (met [TEST] erachter) te activeren (haal hiervoor de commentaartekens
-- weg) en vervolgens het hele bestand uit te voeren. Hiervoor moet je de
-- testsuite in de database hebben geladen (bedrijf_postgresql_test.sql).
-- NB: niet alle opdrachten hebben testregels.
--
-- Lever je werk pas in op Canvas als alle tests slagen.
-- ------------------------------------------------------------------------


-- S5.1.
-- Welke medewerkers hebben zowel de Java als de XML cursus
-- gevolgd? Geef hun personeelsnummers.
DROP VIEW IF EXISTS s5_1; CREATE OR REPLACE VIEW s5_1 AS                                                     -- [TEST]
SELECT cursist
FROM inschrijvingen
WHERE cursus = 'XML'
AND cursist IN 
    (SELECT cursist 
     FROM inschrijvingen 
     WHERE cursus = 'JAV');


-- S5.2.
-- Geef de nummers van alle medewerkers die niet aan de afdeling 'OPLEIDINGEN'
-- zijn verbonden.
DROP VIEW IF EXISTS s5_2; CREATE OR REPLACE VIEW s5_2 AS                                                     -- [TEST]
SELECT mnr
FROM medewerkers m
WHERE EXISTS (
    SELECT 1
    FROM afdelingen a
    WHERE a.anr = m.afd
    AND a.naam != 'OPLEIDINGEN'
);


-- S5.3.
-- Geef de nummers van alle medewerkers die de Java-cursus niet hebben
-- gevolgd.
DROP VIEW IF EXISTS s5_3; CREATE OR REPLACE VIEW s5_3 AS                                                     -- [TEST]
SELECT emp.mnr
FROM medewerkers emp
WHERE emp.mnr NOT IN (
    SELECT reg.cursist
    FROM inschrijvingen reg
    WHERE reg.cursus = 'JAV'
);


-- S5.4.
-- a. Welke medewerkers hebben ondergeschikten? Geef hun naam.
DROP VIEW IF EXISTS s5_4a; CREATE OR REPLACE VIEW s5_4a AS                                                   -- [TEST]
SELECT m.naam
FROM medewerkers m
WHERE m.mnr IN (
    SELECT chef
    FROM medewerkers
    WHERE chef IS NOT NULL
);


-- b. En welke medewerkers hebben geen ondergeschikten? Geef wederom de naam.
DROP VIEW IF EXISTS s5_4b; CREATE OR REPLACE VIEW s5_4b AS                                                   -- [TEST]
SELECT naam
FROM medewerkers
WHERE mnr NOT IN (
    SELECT chef
    FROM medewerkers
    WHERE chef IS NOT NULL
);


-- S5.5.
-- Geef cursuscode en begindatum van alle uitvoeringen van programmeercursussen
-- ('BLD') in 2020.
DROP VIEW IF EXISTS s5_5; CREATE OR REPLACE VIEW s5_5 AS                                                     -- [TEST]
SELECT cursus, begindatum
FROM uitvoeringen
WHERE cursus IN (
    SELECT code
    FROM cursussen
    WHERE type = 'BLD'
)
AND begindatum BETWEEN '2020-01-01' AND '2020-12-30';


-- S5.6.
-- Geef van alle cursusuitvoeringen: de cursuscode, de begindatum en het
-- aantal inschrijvingen (`aantal_inschrijvingen`). Sorteer op begindatum.
DROP VIEW IF EXISTS s5_6; CREATE OR REPLACE VIEW s5_6 AS                                                     -- [TEST]
SELECT
    cursus,
    begindatum,
    (SELECT COUNT(*)
     FROM inschrijvingen i
     WHERE i.cursus = u.cursus AND i.begindatum = u.begindatum) AS aantal_inschrijvingen
FROM
    uitvoeringen u
ORDER BY
    begindatum;


-- S5.7.
-- Geef voorletter(s) en achternaam van alle trainers die ooit tijdens een
-- algemene ('ALG') cursus hun eigen chef als cursist hebben gehad.
DROP VIEW IF EXISTS s5_7; CREATE OR REPLACE VIEW s5_7 AS                                                     -- [TEST]
SELECT DISTINCT m.voorl, m.naam
FROM medewerkers m
WHERE m.mnr IN (
    SELECT DISTINCT u.docent
    FROM uitvoeringen u
    WHERE EXISTS (
        SELECT *
        FROM inschrijvingen i
        WHERE u.cursus = i.cursus AND u.begindatum = i.begindatum
        AND i.cursist IN (
            SELECT chef.mnr
            FROM medewerkers chef
            WHERE m.chef = chef.mnr
        )
    )
    AND u.cursus IN (
        SELECT code
        FROM cursussen
        WHERE type = 'ALG'
    )
);


-- S5.8.
-- Geef de naam van de medewerkers die nog nooit een cursus hebben gegeven.
DROP VIEW IF EXISTS s5_8; CREATE OR REPLACE VIEW s5_8 AS                                                     -- [TEST]
SELECT naam
FROM medewerkers
WHERE mnr NOT IN (SELECT docent FROM uitvoeringen WHERE docent IS NOT NULL);



-- -------------------------[ HU TESTRAAMWERK ]--------------------------------
-- Met onderstaande query kun je je code testen. Zie bovenaan dit bestand
-- voor uitleg.

SELECT * FROM test_select('S5.1') AS resultaat
UNION
SELECT * FROM test_select('S5.2') AS resultaat
UNION
SELECT * FROM test_select('S5.3') AS resultaat
UNION
SELECT * FROM test_select('S5.4a') AS resultaat
UNION
SELECT * FROM test_select('S5.4b') AS resultaat
UNION
SELECT * FROM test_select('S5.5') AS resultaat
UNION
SELECT * FROM test_select('S5.6') AS resultaat
UNION
SELECT * FROM test_select('S5.7') AS resultaat
UNION
SELECT * FROM test_select('S5.8') AS resultaat
ORDER BY resultaat;