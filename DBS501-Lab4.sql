-- Name: Phan Trung Kien
-- StudentID: 123266231

-- 1. Write a function 
CREATE OR REPLACE FUNCTION pig_latin (
    pName in CHAR
)   RETURN VARCHAR2
IS
    fixLetter CHAR(1);
    firstLetter CHAR(1);
    restName VARCHAR2(100);
    pigName  VARCHAR2(100);
BEGIN
    IF pName IS NULL THEN
        RETURN null;
    END IF;
    -- Set the substring to test letter in word
    fixLetter := SUBSTR(TRIM(pName),1 ,1);
    firstLetter := LOWER(fixLetter);
    restName := SUBSTR(TRIM(pName),2);
    -- Check if word contains one of these vowels
    IF firstLetter IN ('a', 'e', 'i', 'o', 'u') THEN
        pigName := TRIM(pName) || 'ay';
    -- Check if the word begins with a vowel
    ELSE
        pigName := restName || firstLetter || 'ay';
    END IF;
    
    RETURN pigName;
END;
/
-- Enable output
SET SERVEROUTPUT ON;

-- Test Pig Latin on individual names
BEGIN
    DBMS_OUTPUT.PUT_LINE('Harrison -> ' || pig_latin('Harrison')); -- Expected: arrisonhay
    DBMS_OUTPUT.PUT_LINE('Smith -> ' || pig_latin('Smith'));       -- Expected: mithsay
    DBMS_OUTPUT.PUT_LINE('Anderson -> ' || pig_latin('Anderson')); -- Expected: Andersonay
    DBMS_OUTPUT.PUT_LINE('Urly -> ' || pig_latin('Urly'));         -- Expected: Urlyay
END;
/

-- Test on staff table
SELECT name, pig_latin(name) AS pig_latin_name
FROM staff;
/

-- 2. Write a function "experience" 
CREATE OR REPLACE FUNCTION experience(
    ex_years IN NUMBER
) RETURN VARCHAR2
IS
    slevel VARCHAR2(20);
BEGIN
    -- Check the column "years" in STAFF table is NULL 
    IF ex_years IS NULL THEN
        slevel := 'Unknown';
    -- Check the column "years" in STAFF table is level-expereience
    ELSIF ex_years BETWEEN 0 AND 4 THEN
        slevel := 'Junior';
    ELSIF ex_years BETWEEN 5 AND 9 THEN
        slevel := 'Intermediate';
    ELSIF ex_years >= 10 THEN
        slevel := 'Experienced';
    -- Check the column "years" in STAFF table is Invalid if outside of rangee
    ELSE
        slevel := 'Invalid No.'; -- Handles negative years (optional)
    END IF;

    RETURN slevel;
END;
/

SET SERVEROUTPUT ON;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Years: 2 -> ' || experience(2));  -- Junior
    DBMS_OUTPUT.PUT_LINE('Years: 7 -> ' || experience(7));  -- Intermediate
    DBMS_OUTPUT.PUT_LINE('Years: 12 -> ' || experience(12)); -- Experienced
    DBMS_OUTPUT.PUT_LINE('Years: -1 -> ' || experience(-1)); -- Invalid
    DBMS_OUTPUT.PUT_LINE('Years: 0 -> ' || experience(0)); -- Junior
    DBMS_OUTPUT.PUT_LINE('Years: 5 -> ' || experience(5)); -- Invalid
    DBMS_OUTPUT.PUT_LINE('Years: 9 -> ' || experience(9)); -- Invalid
END;
/

SELECT id, name, years, experience(years) AS experience_level
FROM staff;
/