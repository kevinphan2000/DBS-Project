-- Name: Phan Trung Kien (Kevin)
-- StudentID: 123266231

-- 1. Write a trigger called trigcom 
-- desc STAFF;
-- DROP TABLE STAFF;
-- DROP TABLE salaud;

-- create STAFF table to store values and error records
create table staff (ID smallint, NAME varchar(9), DEPT smallint, JOB char(5), YEARS smallint, SALARY decimal(7,2), COMM decimal(7,2));
-- Create SALAUD table to store values and error records
CREATE TABLE SALAUD (
    ID NUMBER,
    ENTRY_DATE DATE,
    SALARY NUMBER(10, 2),
    COMM NUMBER(10, 2),
    ERROR_CODE VARCHAR2(100)
);
/

CREATE OR REPLACE TRIGGER trigcom
AFTER INSERT OR UPDATE ON STAFF
FOR EACH ROW
DECLARE
    error_message VARCHAR2(200);
BEGIN
    -- Check rule (a): COMMISSION should not be more than 25% of SALARY
    IF :NEW.COMM > (0.25 * :NEW.SALARY) THEN
        error_message := 'Error of Rule A: COMMISSION exceeds 25% of SALARY';
        -- Insert into SALAUD if rule (a) is violated
        INSERT INTO SALAUD (ID, ENTRY_DATE, SALARY, COMM, ERROR_CODE)
        VALUES (:NEW.ID, SYSDATE, :NEW.SALARY, :NEW.COMM, error_message);
    END IF;

    -- Check rule (b): The sum of SALARY and COMM should be at least 50,000
    IF (:NEW.SALARY + :NEW.COMM) < 50000 THEN
        IF error_message IS NULL THEN
            error_message := 'Error of Rule B: SUM of SALARY and COMMISSION < 50,000';
        ELSE
            error_message := error_message || ' and ' || 'Rule (b) is broken';
        END IF;
        INSERT INTO SALAUD (ID,  SALARY, COMM, ERROR_CODE)
        VALUES (:NEW.ID, :NEW.SALARY, :NEW.COMM, error_message);
    END IF;
END;
/

-- Insert a record that adheres to both rules
INSERT INTO STAFF (ID, SALARY, COMM) VALUES (1, 60000, 10000);

INSERT INTO STAFF (ID, SALARY, COMM) VALUES (2, 60000, 20000);

INSERT INTO STAFF (ID, SALARY, COMM) VALUES (6, 20000, 2000);

INSERT INTO STAFF (ID, SALARY, COMM) VALUES (4, 25000, 6001);

INSERT INTO STAFF (ID, SALARY, COMM) VALUES (3, 15000, 5000);

UPDATE STAFF SET SALARY = 70000, COMM = 14000 WHERE ID = 1;

UPDATE STAFF SET SALARY = 25000, COMM = 10000 WHERE ID = 4;

UPDATE STAFF SET SALARY = 15000, COMM = 3000 WHERE ID = 6;

-- Check the STAFF table
SELECT * FROM STAFF;

-- Check the SALAUD table (should be empty)
SELECT * FROM SALAUD;
/


