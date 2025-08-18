-- 1. Write a procedure "array-date" 
CREATE OR REPLACE PROCEDURE array_date (
    sdays   IN  SYS.ODCINUMBERLIST,  -- Array of proper day numbers 
    smonths IN  SYS.ODCINUMBERLIST   -- Array of proper month numbers 
)
IS
    v_date     DATE;
    v_day_name VARCHAR2(40);
    v_month    VARCHAR2(40);
BEGIN
    FOR i IN 1 .. smonths.COUNT LOOP
        FOR j IN 1 .. sdays.COUNT LOOP
            BEGIN
                -- Use to create a valid date
                v_date := TO_DATE(sdays(j) || '-' || smonths(i) || '-2022', 'DD-MM-YYYY');
                
                -- Get the date time
                v_day_name := TRIM(TO_CHAR(v_date, 'Day'));
                v_month    := TRIM(TO_CHAR(v_date, 'Month'));
                
                -- Output the result in the given format
                DBMS_OUTPUT.PUT_LINE(
                    v_day_name || ', ' || v_month || ' ' ||
                    TO_CHAR(v_date, 'FMDD') || ', ' ||
                    TO_CHAR(v_date, 'YYYY')
                );
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('This is Invalid Date!');
            END;
        END LOOP;
    END LOOP;
END;
/


SET SERVEROUTPUT ON;

BEGIN
  array_date(SYS.ODCINUMBERLIST(1, 5, 7), SYS.ODCINUMBERLIST(6, 8));
  array_date(SYS.ODCINUMBERLIST(30, 10, 19), SYS.ODCINUMBERLIST(2, 4));
  array_date(SYS.ODCINUMBERLIST(30, 10, 19), SYS.ODCINUMBERLIST(1, 12));
  array_date(SYS.ODCINUMBERLIST(31, 10, 19), SYS.ODCINUMBERLIST(4, 10));
END;
/


-- 2. Write a stored procedure called name_fun
CREATE OR REPLACE PROCEDURE name_fun IS
    CURSOR emp_cursor IS
        SELECT last_name FROM employees;
    
    lastName      VARCHAR2(100);
    firstChar     CHAR(1);
    v_transformed    VARCHAR2(100);
    v_result         VARCHAR2(100);
BEGIN
    FOR emp_rec IN emp_cursor LOOP
        lastName := emp_rec.last_name;
        firstChar := SUBSTR(lastName, 1, 1);

        CASE 
            WHEN LOWER(firstChar) IN ('a', 'e', 'i', 'o', 'u') THEN
                NULL;  
            ELSE
            -- Change character  all vowels with '*'
                v_transformed := REGEXP_REPLACE(lastName, '[aeiouAEIOU]', '*');
                -- Check the first character in names
                IF firstChar = UPPER(firstChar) THEN
                    v_result := UPPER(SUBSTR(v_transformed, 1, 1)) || 
                                SUBSTR(v_transformed, 2);
                ELSE
                    v_result := LOWER(SUBSTR(v_transformed, 1, 1)) || 
                                SUBSTR(v_transformed, 2);
                END IF;

                -- Make sure the result with 15 characters including '+'
                v_result := RPAD(v_result, 15, '+');
                DBMS_OUTPUT.PUT_LINE(v_result);
        END CASE;
    END LOOP;
END;
/


SET SERVEROUTPUT ON;

-- Call the procedure
BEGIN
    name_fun;
END;
/
