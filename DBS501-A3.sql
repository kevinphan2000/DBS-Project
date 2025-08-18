-- Name: Phan Trung Kien
-- StudentID: 123266231
--Assignment 3:

-- 1. Preparation:
CREATE TABLE EMPAUDIT (
    EMPID        NUMBER(10) NOT NULL,      -- Employee identifier
    ERRORCODE    CHAR(1) NOT NULL,         -- Error code: S, B, C, M
    OPERATION    CHAR(1) NOT NULL,         -- Operation: I, U, D
    WORKDEPT     CHAR(3 BYTE),             
    SALARY       NUMBER(10,2),             
    COMM         NUMBER(10,2),             
    BONUS        NUMBER(10,2)             
);

CREATE TABLE VACATION (
    EMPID CHAR(10) NOT NULL,
    HIREDATE DATE NOT NULL,
    VACATION_DAYS NUMBER(3) NOT NULL
);


ALTER SESSION SET PLSCOPE_SETTINGS = 'IDENTIFIERS:NONE';

-- 2. Write a trigger "varpaychk"
CREATE OR REPLACE TRIGGER varpaychk
AFTER INSERT OR UPDATE ON EMPLOYEE
FOR EACH ROW
DECLARE
    ops CHAR(1);
BEGIN
    IF INSERTING THEN
        ops := 'I';
    ELSE
        ops := 'U';
    END IF;

    IF :NEW.BONUS >= 0.2 * :NEW.SALARY THEN
        INSERT INTO EMPAUDIT VALUES (:NEW.EMPNO, 'B', ops, 'N/A', :NEW.SALARY, :NEW.COMM, :NEW.BONUS);
    END IF;

    IF :NEW.COMM >= 0.25 * :NEW.SALARY THEN
        INSERT INTO EMPAUDIT VALUES (:NEW.EMPNO, 'C', ops, 'N/A', :NEW.SALARY, :NEW.COMM, :NEW.BONUS);
    END IF;
    -- Check if Bonus and commission are more than 40% of salary
    IF :NEW.BONUS + :NEW.COMM >= 0.4 * :NEW.SALARY THEN
        INSERT INTO EMPAUDIT VALUES (:NEW.EMPNO, 'S', ops, 'N/A', :NEW.SALARY, :NEW.COMM, :NEW.BONUS);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error output in Varpaychk');
END;
/


INSERT INTO EMPLOYEE (EMPNO, FIRSTNAME, MIDINIT, LASTNAME, WORKDEPT, PHONENO, HIREDATE, JOB, EDLEVEL, SEX, BIRTHDATE, SALARY, BONUS, COMM)
VALUES ('000001', 'John', 'D', 'Doe', 'D01', '5551', TO_DATE('2021-06-01', 'YYYY-MM-DD'), 'Manager', 4, 'M', TO_DATE('1985-09-15', 'YYYY-MM-DD'), 50000, 11000, 14000);
/
UPDATE EMPLOYEE
SET BONUS = 12000, COMM = 15000
WHERE EMPNO = '000001';
/
SELECT * FROM EMPAUDIT;
/

-- 3: Write a trigger "nomgr"
CREATE OR REPLACE TRIGGER nomgr
BEFORE INSERT OR UPDATE OR DELETE ON EMPLOYEE
FOR EACH ROW
DECLARE
    mgr_count NUMBER := 0;
    orig_dept CHAR(3);
    dept_code CHAR(3);
BEGIN
    -- Handle INSERT operations
    IF INSERTING THEN
        orig_dept := :NEW.WORKDEPT;
        
        IF :NEW.JOB != 'MANAGER' AND :NEW.WORKDEPT != '000' THEN
            BEGIN
                SELECT COUNT(*) INTO mgr_count
                FROM EMPLOYEE
                WHERE WORKDEPT = :NEW.WORKDEPT
                AND JOB = 'MANAGER';
                
                IF mgr_count = 0 THEN
                    :NEW.WORKDEPT := '000';
                    INSERT INTO EMPAUDIT (EMPID, ERRORCODE, OPERATION, WORKDEPT, SALARY, COMM, BONUS)
                    VALUES (TO_NUMBER(:NEW.EMPNO), 'M', 'I', orig_dept, 
                           :NEW.SALARY, :NEW.COMM, :NEW.BONUS);
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    -- Log error but allow operation to continue
                    INSERT INTO EMPAUDIT (EMPID, ERRORCODE, OPERATION, WORKDEPT, SALARY, COMM, BONUS)
                    VALUES (TO_NUMBER(:NEW.EMPNO), 'M', 'I', orig_dept, 
                           :NEW.SALARY, :NEW.COMM, :NEW.BONUS);
            END;
        END IF;
    
    -- Handle UPDATE operations
    ELSIF UPDATING THEN
        orig_dept := :NEW.WORKDEPT;
        
        IF :NEW.JOB != 'MANAGER' AND :NEW.WORKDEPT != '000' AND 
           (:OLD.WORKDEPT != :NEW.WORKDEPT OR :OLD.JOB != :NEW.JOB) THEN
            BEGIN
                SELECT COUNT(*) INTO mgr_count
                FROM EMPLOYEE
                WHERE WORKDEPT = :NEW.WORKDEPT
                AND JOB = 'MANAGER'
                AND EMPNO != :NEW.EMPNO;
                
                IF mgr_count = 0 THEN
                    :NEW.WORKDEPT := '000';
                    INSERT INTO EMPAUDIT (EMPID, ERRORCODE, OPERATION, WORKDEPT, SALARY, COMM, BONUS)
                    VALUES (TO_NUMBER(:NEW.EMPNO), 'M', 'U', orig_dept, 
                           :NEW.SALARY, :NEW.COMM, :NEW.BONUS);
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    -- Log error but allow operation to continue
                    INSERT INTO EMPAUDIT (EMPID, ERRORCODE, OPERATION, WORKDEPT, SALARY, COMM, BONUS)
                    VALUES (TO_NUMBER(:NEW.EMPNO), 'M', 'U', orig_dept, 
                           :NEW.SALARY, :NEW.COMM, :NEW.BONUS);
            END;
        END IF;
    
    -- Handle DELETE operations
    ELSIF DELETING THEN
        dept_code := :OLD.WORKDEPT;
        
        IF :OLD.JOB = 'MANAGER' AND :OLD.WORKDEPT != '000' THEN
            BEGIN
                UPDATE EMPLOYEE
                SET WORKDEPT = '000'
                WHERE WORKDEPT = dept_code
                AND JOB != 'MANAGER';
                
                INSERT INTO EMPAUDIT (EMPID, ERRORCODE, OPERATION, WORKDEPT, SALARY, COMM, BONUS)
                SELECT TO_NUMBER(EMPNO), 'M', 'U', dept_code, SALARY, COMM, BONUS
                FROM EMPLOYEE
                WHERE WORKDEPT = '000'
                AND WORKDEPT != dept_code;
            EXCEPTION
                WHEN OTHERS THEN
                    INSERT INTO EMPAUDIT (EMPID, ERRORCODE, OPERATION, WORKDEPT, SALARY, COMM, BONUS)
                    VALUES (TO_NUMBER(:OLD.EMPNO), 'M', 'D', dept_code, 
                           :OLD.SALARY, :OLD.COMM, :OLD.BONUS);
            END;
        END IF;
    END IF;
END;
/

DELETE FROM EMPLOYEE WHERE WORKDEPT = 'A00' AND JOB = 'MANAGER';


INSERT INTO EMPLOYEE (EMPNO, FIRSTNAME, LASTNAME, WORKDEPT, JOB, SALARY, HIREDATE)
VALUES ('999991', 'John', 'Doe', 'A01', 'DESIGNER', 50000, TO_DATE('2020-01-15', 'YYYY-MM-DD'));

SELECT EMPNO, FIRSTNAME, LASTNAME, WORKDEPT FROM EMPLOYEE WHERE EMPNO = '999991';

SELECT * FROM EMPAUDIT WHERE EMPID = 999991 AND ERRORCODE = 'M';

INSERT INTO EMPLOYEE (EMPNO, FIRSTNAME, LASTNAME, WORKDEPT, JOB, SALARY, HIREDATE)
VALUES ('999992', 'Jane', 'Smith', '000', 'ANALYST', 55000, TO_DATE('2019-05-20', 'YYYY-MM-DD'));

DELETE FROM EMPLOYEE WHERE WORKDEPT = 'B01' AND JOB = 'MANAGER';

-- Test Execution
UPDATE EMPLOYEE 
SET WORKDEPT = 'B01' 
WHERE EMPNO = '999992';

-- Verification
SELECT EMPNO, WORKDEPT FROM EMPLOYEE WHERE EMPNO = '999992';

SELECT * FROM EMPAUDIT WHERE EMPID = 999992 AND ERRORCODE = 'M';


INSERT ALL
        INTO employee (empno, firstname, lastname, workdept, job, salary, bonus, comm)
            VALUES ('888801', 'Correct', 'Varpychk', 'C01', 'Test', 88888, 8888, 8888)
        INTO employee (empno, firstname, lastname, workdept, job, salary, bonus, comm)
            VALUES ('888802', 'Fail', 'Bonus', 'C01', 'Test', 88888, 18888, 8888)
        INTO employee (empno, firstname, lastname, workdept, job, salary, bonus, comm)
            VALUES ('888803', 'Fail', 'Commission', 'C01', 'Test', 88888, 8888, 23000)
        INTO employee (empno, firstname, lastname, workdept, job, salary, bonus, comm)
            VALUES ('888804', 'Fail', 'Sum', 'C01', 'Test', 88888, 17000, 22000)
        INTO employee (empno, firstname, lastname, workdept, job, salary, bonus, comm)
            VALUES ('888805', 'Fail', 'All', 'C01', 'Test', 88888, 28888, 28888)
    SELECT * FROM dual;
    
select count(*) from employee where workdept = 'C01' and job = 'MANAGER';
select * from EMPAUDIT;

-- 4: Write a trigger "empvac"
CREATE OR REPLACE TRIGGER empvac
AFTER INSERT OR UPDATE OR DELETE
ON EMPLOYEE
FOR EACH ROW
DECLARE
    vacation_days NUMBER;
    years_of_service NUMBER;
BEGIN
    -- For INSERT or UPDATE operations
    IF INSERTING OR UPDATING THEN
        -- Ensure HIREDATE is not NULL
        IF :NEW.HIREDATE IS NOT NULL THEN
            -- Calculate the number of years since the employee's hire date
            years_of_service := FLOOR(MONTHS_BETWEEN(SYSDATE, :NEW.HIREDATE)/12);

            IF years_of_service < 10 THEN  -- Less than 10 years
                vacation_days := 15;
            ELSIF years_of_service BETWEEN 10 AND 19 THEN  -- 10-19 years
                vacation_days := 20;
            ELSIF years_of_service BETWEEN 20 AND 29 THEN  -- 20-29 years
                vacation_days := 25;
            ELSE  
                vacation_days := 30;
            END IF;

            -- Check if the employee already has a vacation record
            SELECT COUNT(*) INTO years_of_service
            FROM VACATION
            WHERE EMPID = :NEW.EMPNO;  

            IF years_of_service = 0 THEN
                INSERT INTO VACATION (EMPID, VACATION_DAYS, HIREDATE)
                VALUES (:NEW.EMPNO, vacation_days, :NEW.HIREDATE);  -- Insert EMPID, vacation_days, and HIREDATE
            ELSE
                -- If a vacation record exists, update it
                UPDATE VACATION
                SET VACATION_DAYS = vacation_days, HIREDATE = :NEW.HIREDATE
                WHERE EMPID = :NEW.EMPNO;  
            END IF;
        ELSE
            -- Handle case when HIREDATE is NULL (optional: log an error or set default value)
            RAISE_APPLICATION_ERROR(-20001, 'HIREDATE column cannot be NULL value');
        END IF;
        
    -- For DELETE operation
    ELSIF DELETING THEN
        -- DELETE FROM VACATION WHERE EMPID = :OLD.EMPNO;  
        DELETE FROM VACATION WHERE EMPID = TO_NUMBER(:OLD.EMPNO);
    END IF;
EXCEPTION
WHEN OTHERS THEN
    -- Log error but allow operation to continue
    DBMS_OUTPUT.PUT_LINE('Error in empvac trigger: ' || SQLERRM);
END empvac;
/


ALTER TRIGGER empvac COMPILE;


-- TEST a trigger "Empvac"
INSERT INTO EMPLOYEE (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm)
VALUES ('200430', 'John', 'A', 'Doe', 'A01', '1234', TO_DATE('2018-01-01', 'YYYY-MM-DD'), 'CLERK', 12, 'M', TO_DATE('1990-01-01', 'YYYY-MM-DD'), 60000, 1000, 500);

INSERT INTO EMPLOYEE (EMPNO, FIRSTNAME, LASTNAME, WORKDEPT, JOB, SALARY, HIREDATE)
VALUES ('999996', 'Emily', 'Johnson', 'D01', 'DESIGNER', 65000, TO_DATE('2018-06-10', 'YYYY-MM-DD'));

UPDATE EMPLOYEE
SET HIREDATE = TO_DATE('2000-01-20', 'YYYY-MM-DD')
WHERE EMPNO = '999996';


INSERT INTO EMPLOYEE (EMPNO, FIRSTNAME, LASTNAME, WORKDEPT, JOB, SALARY, HIREDATE)
VALUES ('999998', 'Sarah', 'Wilson', 'F01', 'MGR', 85000, TO_DATE('1990-11-01', 'YYYY-MM-DD'));

-- Verify vacation record exists
SELECT COUNT(*) FROM VACATION WHERE EMPID = 999998;


-- Verify both records deleted
SELECT COUNT(*) FROM VACATION WHERE EMPID = 999998;
SELECT COUNT(*) FROM EMPLOYEE WHERE EMPNO = '999998';

select * from vacation;

DELETE FROM EMPLOYEE WHERE EMPNO = '999998';
DELETE FROM EMPLOYEE WHERE EMPNO = '999996';
DELETE FROM EMPLOYEE WHERE EMPNO = '200430';

select * from vacation;




