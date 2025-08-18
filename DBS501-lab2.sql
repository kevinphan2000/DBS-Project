-- Name: Phan Trung Kien (Kevin)
-- Student ID: 123266231
-- 1. factorial function gets an integer number n 
CREATE OR REPLACE FUNCTION factorial(n in number)
    RETURN number IS
BEGIN
    IF n = 0 OR n = 1 THEN
        RETURN n;
    ELSE
        RETURN n * factorial(n-1);
    END IF;
END;
/

SET SERVEROUTPUT ON;

BEGIN
  DBMS_OUTPUT.PUT_LINE('5! = ' || factorial(5));
END;
/
BEGIN
  DBMS_OUTPUT.PUT_LINE('1! = ' || factorial(1));
END;
/

DROP FUNCTION factorial;

-- 2. fibonacci that gets an integer number n 
CREATE OR REPLACE PROCEDURE fibonacci(n IN NUMBER) AS
    first NUMBER := 0;
    second NUMBER := 1;
    temp NUMBER;
    i NUMBER;
BEGIN
-- check condition positive number
    IF n <= 0 THEN
        dbms_output.put_line('Please enter a positive integer.');
        RETURN;
    END IF;
    dbms_output.put_line('Series:');
    dbms_output.put_line(first);
    dbms_output.put_line(second);

    FOR i IN 2..n - 1 LOOP
        temp := first + second;
        first := second;
        second := temp;
        dbms_output.put_line(temp);
    END LOOP;
END;
/
-- Testcases: fibonnacci

BEGIN
    fibonacci(5);
END;
/
BEGIN
    fibonacci(1);
END;
/
BEGIN
    fibonacci(0);
END;
/
-- 3. Update the price by cat 
CREATE OR REPLACE PROCEDURE update_price_cat(
    p_category_id IN products.category_id%TYPE,
    p_amount IN NUMBER
) AS
    rows_updated NUMBER;
BEGIN
    UPDATE products
    SET list_price = list_price + p_amount
    WHERE category_id = p_category_id
        AND list_price > 0;
    
    rows_updated := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('Number of rows updated: ' || rows_updated);
EXCEPTION 
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An Error Occurred: ' || SQLERRM);
END;
/

SET SERVEROUTPUT ON;
BEGIN
    update_price_cat(1, 5);
END;
/


-- 4. Update price under the average
CREATE OR REPLACE PROCEDURE update_price_under_avg AS
    v_avg_price     products.list_price%TYPE;
    rows_updated    NUMBER;
BEGIN
    -- Calculate the average list price from products
    SELECT AVG(list_price) INTO v_avg_price FROM products;
    -- If the average price is less than or equal to $1000
    IF v_avg_price <= 1000 THEN
        UPDATE products
        SET list_price = list_price * 1.02          -- 
        WHERE list_price < v_avg_price;
    ELSE
        UPDATE products
        SET list_price = list_price * 1.01
        WHERE list_price < v_avg_price;
    END IF;

    rows_updated := SQL%ROWCOUNT;

    DBMS_OUTPUT.PUT_LINE('Average price: ' || TO_CHAR(v_avg_price, '9999.99'));
    DBMS_OUTPUT.PUT_LINE('Number of rows updated: ' || rows_updated);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

SET SERVEROUTPUT ON;
BEGIN
    update_price_under_avg;
END;
/

-- 5. Write a procedure named product_price_report to show the number of products
CREATE OR REPLACE PROCEDURE product_price_report AS
    v_avg_price     products.list_price%TYPE;
    v_min_price     products.list_price%TYPE;
    v_max_price     products.list_price%TYPE;

    cheap_threshold  NUMBER;
    exp_threshold    NUMBER;

    cheap_count      NUMBER := 0;
    fair_count       NUMBER := 0;
    exp_count        NUMBER := 0;
BEGIN
    SELECT AVG(list_price), MIN(list_price), MAX(list_price)
    INTO v_avg_price, v_min_price, v_max_price
    FROM products;

    cheap_threshold := (v_avg_price - v_min_price) / 2;
    exp_threshold   := (v_max_price - v_avg_price) / 2;

    SELECT
        COUNT(CASE WHEN list_price < cheap_threshold THEN 1 END),
        COUNT(CASE WHEN list_price > exp_threshold THEN 1 END),
        COUNT(CASE WHEN list_price >= cheap_threshold AND list_price <= exp_threshold THEN 1 END)
    INTO cheap_count, exp_count, fair_count
    FROM products;

    DBMS_OUTPUT.PUT_LINE('Cheap: ' || cheap_count);
    DBMS_OUTPUT.PUT_LINE('Fair: ' || fair_count);
    DBMS_OUTPUT.PUT_LINE('Expensive: ' || exp_count);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;
/

SET SERVEROUTPUT ON;
BEGIN
    product_price_report;
END;
/

