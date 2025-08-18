-- Name: Phan Trung Kien
-- StudentID; 123266231

-- 1. Preparation:

-- 2. Write a procedure called staff_add
CREATE OR REPLACE PROCEDURE staff_add (
    N_name      IN staff.name%TYPE,
    N_job       IN staff.job%TYPE,
    N_salary    IN staff.salary%TYPE,
    N_comm      IN staff.comm%TYPE
)
IS
    max_id staff.id%TYPE;
    new_id staff.id%TYPE;
    valid_job BOOLEAN := FALSE;
BEGIN
    SELECT NVL(MAX(id), 0) INTO max_id FROM staff;
    new_id := max_id + 10;

    if upper(N_job) in ('SALES', 'CLERK', 'MGR') then
        valid_job := TRUE;
    end if;

    if not valid_job then
        raise_application_error(-2001, 'Invalid job title. Must be Clerk, Sales or Mgr');
    end if;
    
INSERT INTO staff(id, name, dept, job, years, salary, comm)
VALUES (new_id, N_name, 90, N_job, 1, N_salary, N_comm);

DBMS_OUTPUT.PUT_LINE('Staff member added successfully. ID: ' || new_id);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END;
/
-------------------------------------------------------------
-- Testing
-------------------------------------------------------------
SET SERVEROUTPUT ON;
BEGIN
    staff_add('Samuel', 'Sales', 100.00, 200.00);
END;
/



-- 3. Create an INSERT trigger ins_job to enhance the error checking on the JOB column,
Create Table STAFFAUDTBL(
    ID int,
    INCJOB varchar(100),
    OLDCOMM DECIMAL(18,2),
    NEWCOMM DECIMAL(18,2),
    ACTION CHAR(1)
);
/

CREATE OR REPLACE TRIGGER ins_job
AFTER INSERT ON staff
FOR EACH ROW
DECLARE
    v_job VARCHAR2(50);
    v_id INT;
BEGIN
    -- Get the ID and JOB from the newly inserted row
    v_id := :NEW.ID;
    v_job := :NEW.JOB;

    -- Check if the JOB value is invalid
    IF v_job NOT IN ('Sales', 'Clerk', 'Mgr') THEN
        -- Insert the invalid job into STAFFAUDTBL
        INSERT INTO STAFFAUDTBL (ID, INCJOB)
        VALUES (v_id, v_job);
    END IF;
END ins_job;
/
-------------------------------------------------------------
-- Testing
-------------------------------------------------------------
INSERT INTO staff (ID, NAME, JOB, SALARY, COMM, YEARS)
VALUES (890, 'Kiara', 'Proff', 2000, 200, 2);
/
Select * from STAFFAUDTBL;
/


-- 4. Create a function called total_cmp 
CREATE OR REPLACE FUNCTION total_cmp (p_id IN INT) 
RETURN DECIMAL
IS
    v_salary   DECIMAL(9, 2);
    v_comm     DECIMAL(9, 2);
    v_total    DECIMAL(9, 2);
BEGIN
    SELECT SALARY, COMM 
    INTO v_salary, v_comm
    FROM staff
    WHERE ID = p_id;

    v_total := v_salary + v_comm;

    RETURN v_total;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Raise an exception with an error message
        RAISE_APPLICATION_ERROR(-20001, 'Invalid ID provided: ' || p_id);
    
    -- Optional: Handle other potential exceptions, like general errors
    WHEN OTHERS THEN
        RAISE;
END total_cmp;
/

-------------------------------------------------------------
-- Testing
-------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
    v_res NUMBER(18, 2);  -- Declare a variable to hold the result
BEGIN
    -- Call the function and assign the result to v_res
    v_res := total_cmp(360);

    -- Display the result (You can use DBMS_OUTPUT or a SELECT statement for output)
    DBMS_OUTPUT.PUT_LINE('Result for ID 360: ' || v_res);
END;
/



-- 5. Create a stored procedure set_comm
CREATE OR REPLACE PROCEDURE set_comm IS
BEGIN
    -- Update the COMM for each record based on the JOB type
    FOR rec IN (SELECT ID, SALARY, JOB FROM staff) LOOP
        CASE
            WHEN rec.JOB = 'Mgr' THEN
                UPDATE staff
                SET COMM = rec.SALARY * 0.20
                WHERE ID = rec.ID;
            WHEN rec.JOB = 'Clerk' THEN
                UPDATE staff
                SET COMM = rec.SALARY * 0.10
                WHERE ID = rec.ID;
            WHEN rec.JOB = 'Sales' THEN
                UPDATE staff
                SET COMM = rec.SALARY * 0.30
                WHERE ID = rec.ID;
            WHEN rec.JOB = 'Prez' THEN
                UPDATE staff
                SET COMM = rec.SALARY * 0.50
                WHERE ID = rec.ID;
        END CASE;
    END LOOP;
END set_comm;
/

CREATE OR REPLACE TRIGGER upd_comm
AFTER UPDATE ON staff
FOR EACH ROW
BEGIN
    -- Check if COMM has been updated
    IF :NEW.COMM != :OLD.COMM THEN
        -- Insert a record into STAFFAUDTBL with the old and new COMM values
        INSERT INTO STAFFAUDTBL (ID, INCJOB, OLDCOMM, NEWCOMM)
        VALUES (:NEW.ID, NULL, :OLD.COMM, :NEW.COMM);
    END IF;
END upd_comm;
/

--------------------------------------------------
-- Testing
--------------------------------------------------
SELECT * FROM staff WHERE job = 'Mgr';

SELECT * FROM staffaudtbl;

BEGIN
    -- Execute the procedure to set commissions
    staff_pck.set_comm;
END;
/

SELECT * FROM staff WHERE job = 'Mgr';

SELECT * FROM staffaudtbl;

-- 6. Take the 2 triggers you created and combine them into a single trigger "staff_trig"

CREATE OR REPLACE TRIGGER staff_trig
FOR INSERT OR UPDATE OR DELETE ON staff
COMPOUND TRIGGER

  -- Variables shared across all timing points (declare once)
  v_oldComm  staff.comm%TYPE;
  v_newComm  staff.comm%TYPE;
  v_name     staff.name%TYPE;
  v_dept     staff.dept%TYPE;
  v_job      staff.job%TYPE;
  v_years    staff.years%TYPE;
  v_salary   staff.salary%TYPE;
  v_id       staff.id%TYPE;

BEFORE EACH ROW IS
BEGIN
  -- Assign values from :OLD and :NEW depending on operation
  IF INSERTING THEN
    v_newComm := :NEW.comm;
    v_name    := :NEW.name;
    v_dept    := :NEW.dept;
    v_job     := :NEW.job;
    v_years   := :NEW.years;
    v_salary  := :NEW.salary;
    v_id      := :NEW.id;
  
  ELSIF UPDATING THEN
    v_oldComm := :OLD.comm;
    v_newComm := :NEW.comm;
    v_name    := :NEW.name;
    v_dept    := :NEW.dept;
    v_job     := :NEW.job;
    v_years   := :NEW.years;
    v_salary  := :NEW.salary;
    v_id      := :NEW.id;

  ELSIF DELETING THEN
    v_oldComm := :OLD.comm;
    v_name    := :OLD.name;
    v_dept    := :OLD.dept;
    v_job     := :OLD.job;
    v_years   := :OLD.years;
    v_salary  := :OLD.salary;
    v_id      := :OLD.id;
  END IF;
END BEFORE EACH ROW;

-- You can optionally add AFTER EACH ROW or statement-level logic here
-- Example: logging, validation, or audit insert

END staff_trig;
/
-------------------------------------------------------------
-- Insert
-------------------------------------------------------------
CREATE OR REPLACE PROCEDURE upsert_from_staff IS
    CURSOR yucky_cursor IS
        SELECT ID, COMM, NAME, DEPT, JOB, YEARS, SALARY
        FROM staff;

    v_id       staff.id%TYPE;
    v_comm     staff.comm%TYPE;
    v_name     staff.name%TYPE;
    v_dept     staff.dept%TYPE;
    v_job      staff.job%TYPE;
    v_years    staff.years%TYPE;
    v_salary   staff.salary%TYPE;
    v_oldcomm  staff.comm%TYPE;
    v_count    INT;
BEGIN
    OPEN yucky_cursor;
    LOOP
        FETCH yucky_cursor INTO v_id, v_comm, v_name, v_dept, v_job, v_years, v_salary;
        EXIT WHEN yucky_cursor%NOTFOUND;

        -- Check how many records match this ID (should always be 1 unless data is bad)
        SELECT COUNT(*) INTO v_count FROM staff WHERE ID = v_id;

        IF v_count > 0 THEN
            -- Simulate update audit
            SELECT COMM INTO v_oldcomm FROM staff WHERE ID = v_id;

            IF v_oldcomm != v_comm THEN
                INSERT INTO staffaudtbl (ID, INCJOB, OLDCOMM, NEWCOMM, ACTION)
                VALUES (v_id, NULL, v_oldcomm, v_comm, 'U');
            END IF;

            -- Normally update logic would go here, but you're already in staff

        ELSE
            -- Simulate insert logic (job validation)
            IF v_job NOT IN ('Sales', 'Clerk', 'Mgr') THEN
                INSERT INTO staffaudtbl (ID, INCJOB, ACTION)
                VALUES (v_id, v_job, 'I');
            END IF;

            -- INSERT not needed — row is already in staff
        END IF;

    END LOOP;
    CLOSE yucky_cursor;
END;
/

-------------------------------------------------
-- Delete
-------------------------------------------------
CREATE OR REPLACE TRIGGER trg_delete_staff
AFTER DELETE ON staff
FOR EACH ROW
BEGIN
    INSERT INTO STAFFAUDTBL (ID, ACTION)
    VALUES (:OLD.ID, 'D');
END;
/

--------------------------------------------------
-- Testing
--------------------------------------------------
select * from staff;
Select * from STAFFAUDTBL;
Delete  from staff where ID=10;
select * from STAFFAUDTBL;

Select * from STAFFAUDTBL;
Update  staff set Comm=120 where ID=20;
select * from STAFFAUDTBL;

Select * from STAFFAUDTBL where ID=3008;
INSERT INTO [dbo].[staff]([ID],[NAME],[DEPT],[JOB],[YEARS],[SALARY],[COMM]) VALUES
           (3008,'Davis',84,'Staff',5,+65454.50,+00806.10);
select * from STAFFAUDTBL where ID=3008;
/

-------------------------------------------------
-- 7.
-------------------------------------------------
CREATE OR REPLACE FUNCTION fun_name(p_name IN VARCHAR2)
RETURN VARCHAR2
IS
    v_result VARCHAR2(1000) := '';
BEGIN
    FOR i IN 1 .. LENGTH(p_name) LOOP
        IF MOD(i, 2) = 1 THEN  -- Odd index: Uppercase
            v_result := v_result || UPPER(SUBSTR(p_name, i, 1));
        ELSE                   -- Even index: Lowercase
            v_result := v_result || LOWER(SUBSTR(p_name, i, 1));
        END IF;
    END LOOP;

    RETURN v_result;
END fun_name;
/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Testing
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET SERVEROUTPUT ON;

DECLARE
    v_res VARCHAR2(50);
BEGIN
    -- Call the function with 'Smith'
    v_res := fun_name('Smith');
    DBMS_OUTPUT.PUT_LINE('Result for Smith: ' || v_res);

    -- Call the function with 'Robertson'
    v_res := fun_name('Robertson');
    DBMS_OUTPUT.PUT_LINE('Result for Robertson: ' || v_res);
END;
/


----------------------------------------------------
-- 8. vowel_cnt
----------------------------------------------------
CREATE OR REPLACE FUNCTION vowel_cnt (p_columnname IN VARCHAR2)
RETURN INTEGER
IS
    v_name VARCHAR2(50);
    v_count INTEGER := 0;
    v_counter INTEGER := 1;
    v_char CHAR(1);
BEGIN
    -- Loop through each row in the staff table, fetching the column data dynamically
    FOR rec IN (EXECUTE IMMEDIATE 'SELECT ' || p_columnname || ' FROM staff') LOOP
        v_name := rec."COLUMN_NAME";  -- Fetch the column value
        -- Loop through each character of the name string
        FOR i IN 1..LENGTH(v_name) LOOP
            v_char := SUBSTR(v_name, i, 1);
            -- Check if the character is a vowel
            IF v_char IN ('A', 'a', 'E', 'e', 'I', 'i', 'O', 'o', 'U', 'u') THEN
                v_count := v_count + 1;
            END IF;
        END LOOP;
    END LOOP;
    RETURN v_count;
END vowel_cnt;
/




--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Testing
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET SERVEROUTPUT ON;

DECLARE
    v_res VARCHAR2(50);
BEGIN
    -- Call the function for the 'NAME' column
    v_res := vowel_cnt('NAME');
    DBMS_OUTPUT.PUT_LINE('Result for NAME: ' || v_res);

    -- Call the function for the 'JOB' column
    v_res := vowel_cnt('JOB');
    DBMS_OUTPUT.PUT_LINE('Result for JOB: ' || v_res);
END;
/




------------------------------------------------------
-- 9. staff_pck
------------------------------------------------------
CREATE OR REPLACE PACKAGE staff_pck AS

  -- Procedure to add a staff member
  PROCEDURE staff_add(
    name   IN VARCHAR2,
    job    IN VARCHAR2,
    salary IN NUMBER,
    comm   IN NUMBER
  );

  -- Function to calculate total compensation
  FUNCTION total_cmp(
    id IN INTEGER
  ) RETURN NUMBER;

  -- Procedure to set commission based on job
  PROCEDURE set_comm;

  -- Function to alternate upper/lower case letters
  FUNCTION fun_name(
    name IN VARCHAR2
  ) RETURN VARCHAR2;

  -- Function to count vowels in a string
  FUNCTION vowel_cnt(
    p_name IN VARCHAR2
  ) RETURN INTEGER;

END staff_pck;
/

CREATE OR REPLACE PACKAGE BODY staff_pck AS

  PROCEDURE staff_add(name IN VARCHAR2, job IN VARCHAR2, salary IN NUMBER, comm IN NUMBER) IS
    v_id NUMBER;
  BEGIN
    SELECT NVL(MAX(id), 0) + 10 INTO v_id FROM staff;
    INSERT INTO staff (id, name, dept, job, years, salary, comm)
    VALUES (v_id, name, 90, job, 1, salary, comm);
  END;

  FUNCTION total_cmp(id IN INTEGER) RETURN NUMBER IS
    v_total NUMBER := -1;
    v_salary staff.salary%TYPE;
    v_comm   staff.comm%TYPE;
  BEGIN
    SELECT salary, comm INTO v_salary, v_comm
    FROM staff WHERE id = id;
    v_total := v_salary + v_comm;
    RETURN v_total;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN -1;
  END;

  PROCEDURE set_comm IS
  BEGIN
    FOR rec IN (SELECT id, salary, job FROM staff) LOOP
      UPDATE staff
      SET comm = CASE
        WHEN job = 'Mgr' THEN salary * 0.2
        WHEN job = 'Clerk' THEN salary * 0.1
        WHEN job = 'Sales' THEN salary * 0.3
        WHEN job = 'Prez' THEN salary * 0.5
        ELSE comm
      END
      WHERE id = rec.id;
    END LOOP;
  END;

  FUNCTION fun_name(name IN VARCHAR2) RETURN VARCHAR2 IS
    v_result VARCHAR2(1000) := '';
  BEGIN
    FOR i IN 1 .. LENGTH(name) LOOP
      IF MOD(i, 2) = 1 THEN
        v_result := v_result || UPPER(SUBSTR(name, i, 1));
      ELSE
        v_result := v_result || LOWER(SUBSTR(name, i, 1));
      END IF;
    END LOOP;
    RETURN v_result;
  END;

  FUNCTION vowel_cnt(p_name IN VARCHAR2) RETURN INTEGER IS
    v_count INTEGER := 0;
  BEGIN
    FOR i IN 1 .. LENGTH(p_name) LOOP
      IF INSTR('AEIOUaeiou', SUBSTR(p_name, i, 1)) > 0 THEN
        v_count := v_count + 1;
      END IF;
    END LOOP;
    RETURN v_count;
  END;

END staff_pck;
/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Testing
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET SERVEROUTPUT ON;

BEGIN
  DBMS_OUTPUT.PUT_LINE('Name styled: ' || staff_pck.fun_name('Robertson'));
  DBMS_OUTPUT.PUT_LINE('Vowels in Alice: ' || staff_pck.vowel_cnt('Alice'));
END;
/
