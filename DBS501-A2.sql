-- Name: Phan Trung Kien
-- StudentID: 123266231

-- 1. Preparation:
-- Create the EMPLOYEE table
--
-- create table employee (EMPNO char(6), FIRSTNAME varchar(12), MIDINIT char(1), LASTNAME varchar(15), WORKDEPT char(3), PHONENO char(4), HIREDATE date, JOB char(8), EDLEVEL smallint, SEX char(1), BIRTHDATE date, SALARY decimal(9,2), BONUS decimal(9,2), COMM decimal(9,2));
-- Create the STAFF table
--
-- create table staff (ID smallint, NAME varchar(9), DEPT smallint, JOB char(5), YEARS smallint, SALARY decimal(7,2), COMM decimal(7,2));

-- 2. Write a function called "my_median" which takes the values in a column
CREATE OR REPLACE FUNCTION my_median(column_name IN VARCHAR2)
RETURN NUMBER
IS
    v_count    NUMBER;
    v_median   NUMBER;
    v_sql      VARCHAR2(1000);
    colK     NUMBER;
    colK2     NUMBER;
BEGIN
    v_sql := 'SELECT COUNT(' || column_name || ') FROM staff WHERE ' || column_name || ' IS NOT NULL';
    EXECUTE IMMEDIATE v_sql INTO v_count;

    -- Handle empty list
    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: There is no data input cause of empty list');
        RETURN NULL;
    END IF;

    -- If count is odd then print the statement "Added Row"
    IF MOD(v_count, 2) = 1 THEN
        v_sql := 'SELECT AVG(val) FROM (
                    SELECT ' || column_name || ' AS val
                    FROM staff
                    WHERE ' || column_name || ' IS NOT NULL
                    ORDER BY ' || column_name || '
                    OFFSET FLOOR(:1/2) ROWS FETCH NEXT 1 ROWS ONLY
                 )';
        EXECUTE IMMEDIATE v_sql INTO v_median USING v_count;

    -- If count is even then print the statement "Added Row"
    ELSE
        v_sql := 'SELECT ' || column_name || ' FROM (
                    SELECT ' || column_name || '
                    FROM staff
                    WHERE ' || column_name || ' IS NOT NULL
                    ORDER BY ' || column_name || '
                    OFFSET :1 ROWS FETCH NEXT 1 ROWS ONLY
                 )';
        EXECUTE IMMEDIATE v_sql INTO colK USING (v_count/2 - 1);

        v_sql := 'SELECT ' || column_name || ' FROM (
                    SELECT ' || column_name || '
                    FROM staff
                    WHERE ' || column_name || ' IS NOT NULL
                    ORDER BY ' || column_name || '
                    OFFSET :1 ROWS FETCH NEXT 1 ROWS ONLY
                 )';
        EXECUTE IMMEDIATE v_sql INTO colK2 USING (v_count/2);

        v_median := (colK + colK2) / 2;
    END IF;

    RETURN v_median;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('The unexpected error: ' || SQLERRM);
        RETURN NULL;
END;
/


-- Test cases
SET SERVEROUTPUT ON;
SELECT my_median('salary') AS median_even FROM dual;
/
UPDATE staff SET salary = NULL WHERE ROWNUM = 1;
COMMIT;
SELECT my_median('salary') AS median_odd FROM dual;
/
UPDATE staff SET salary = NULL;
COMMIT;
SELECT my_median('salary') AS median_empty FROM dual;
/


-- 3: Write a procedure my_mode
CREATE OR REPLACE FUNCTION my_mode(column_name IN VARCHAR2)
RETURN VARCHAR2
IS
    TYPE new_rec IS RECORD (
        val   VARCHAR2(100),
        freq  NUMBER
    );

    TYPE value_tab IS TABLE OF new_rec;
    v_results value_tab;

    v_sql        VARCHAR2(1000);
    v_max_count  NUMBER := 0;
    v_mode_list  VARCHAR2(4000) := '';
    v_row_count  NUMBER := 0;

BEGIN
    -- Count non-null rows
    v_sql := 'SELECT COUNT(' || column_name || ') FROM staff WHERE ' || column_name || ' IS NOT NULL';
    EXECUTE IMMEDIATE v_sql INTO v_row_count;

    IF v_row_count = 0 THEN
        RETURN 'No data found – empty list';
    END IF;

    -- Build dynamic SQL to collect values and their frequencies
    v_sql := '
        SELECT ' || column_name || ', COUNT(*) AS freq
        FROM staff
        WHERE ' || column_name || ' IS NOT NULL
        GROUP BY ' || column_name || '
        ORDER BY freq DESC
    ';

    -- Execute dynamic SQL and bulk collect results
    EXECUTE IMMEDIATE v_sql BULK COLLECT INTO v_results;

    -- First pass: find max frequency
    FOR i IN 1 .. v_results.COUNT LOOP
        IF i = 1 THEN
            v_max_count := v_results(i).freq;
            v_mode_list := v_results(i).val;
        ELSIF v_results(i).freq = v_max_count THEN
            v_mode_list := v_mode_list || ', ' || v_results(i).val;
        ELSE
            EXIT;
        END IF;
    END LOOP;

    -- Decide response
    IF v_max_count = 1 THEN
        RETURN 'No mode found (all values occur only once)';
    ELSIF INSTR(v_mode_list, ',') > 0 THEN
        RETURN 'Multiple modes: ' || v_mode_list;
    ELSE
        RETURN 'Found Mode: ' || v_mode_list;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Unexpected error: ' || SQLERRM;
END;
/



-- Example: update rows to make DEPT = 10 and 20 appear 5 times each
-- Then test:
SET SERVEROUTPUT ON;

SELECT my_mode('dept') FROM dual;
-- Multiple modes
SELECT my_mode('years') FROM dual;
-- No mode (all unique)
SELECT my_mode('id') FROM dual;


-- 4. Write a procedure called my_math_all which takes the values in a column
CREATE OR REPLACE PROCEDURE my_math_all(column_name IN VARCHAR2) IS
    v_sql        VARCHAR2(1000);
    v_count      NUMBER := 0;
    v_mean       NUMBER;
    v_median     NUMBER;
    v_mode       NUMBER;
    v_mode_freq  NUMBER;
    
    TYPE num_table IS TABLE OF NUMBER;
    v_values     num_table;
BEGIN
    v_sql := 'SELECT ' || column_name || ' FROM staff WHERE ' || column_name || ' IS NOT NULL ORDER BY ' || column_name;
    
    EXECUTE IMMEDIATE v_sql BULK COLLECT INTO v_values;
    v_count := v_values.COUNT;

    -- Check if the list is empty
    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('The list is empty. No data to calculate.');
        RETURN;
    END IF;

    -- Mean using dynamic SQL
    EXECUTE IMMEDIATE 'SELECT AVG(' || column_name || ') FROM staff WHERE ' || column_name || ' IS NOT NULL' INTO v_mean;

    -- Median
    IF MOD(v_count, 2) = 1 THEN
        v_median := v_values((v_count + 1) / 2);
    ELSE
        v_median := (v_values(v_count / 2) + v_values(v_count / 2 + 1)) / 2;
    END IF;

    -- Mode: Look for the item has the most frequent value
    v_sql := '
        SELECT ' || column_name || ', COUNT(*) AS freq
        FROM staff
        WHERE ' || column_name || ' IS NOT NULL
        GROUP BY ' || column_name || '
        ORDER BY freq DESC FETCH FIRST 1 ROWS ONLY';
    
    EXECUTE IMMEDIATE v_sql INTO v_mode, v_mode_freq;

    -- Output results
    DBMS_OUTPUT.PUT_LINE('Column: ' || column_name);
    DBMS_OUTPUT.PUT_LINE('Count : ' || v_count);
    DBMS_OUTPUT.PUT_LINE('Mean  : ' || ROUND(v_mean, 2));
    DBMS_OUTPUT.PUT_LINE('Median: ' || ROUND(v_median, 2));
    DBMS_OUTPUT.PUT_LINE('Mode  : ' || v_mode || ' (Occurred ' || v_mode_freq || ' times)');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/


SET SERVEROUTPUT ON;
BEGIN
    my_math_all('dept');
END;
/
BEGIN
    my_math_all('salary');
END;
/


