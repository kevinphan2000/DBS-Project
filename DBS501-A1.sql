-- NAME: Phan Trung Kien
-- ID: 123266231
-- 1. Write a stored procedure called salary for the EMPLOYEE table which takes as input
CREATE OR REPLACE PROCEDURE salary (
    emNum IN VARCHAR2,
    ratings IN NUMBER
)
IS
    v_old_salary EMPLOYEE.SALARY%TYPE;
    v_old_bonus  EMPLOYEE.BONUS%TYPE;
    v_old_comm   EMPLOYEE.COMM%TYPE;
    v_new_salary EMPLOYEE.SALARY%TYPE;
    v_new_bonus  EMPLOYEE.BONUS%TYPE;
    v_new_comm   EMPLOYEE.COMM%TYPE;
BEGIN
    -- Check if employee exists
    SELECT SALARY, BONUS, COMM
    INTO v_old_salary, v_old_bonus, v_old_comm
    FROM EMPLOYEE
    WHERE EMPNO = emNum;

    -- Handle rating logic
    IF ratings = 1 THEN
        v_new_salary := v_old_salary + 10000;
        v_new_bonus  := v_old_bonus + 300;
        v_new_comm   := v_old_comm + (v_old_salary * 0.05);

    ELSIF ratings = 2 THEN
        v_new_salary := v_old_salary + 5000;
        v_new_bonus  := v_old_bonus + 200;
        v_new_comm   := v_old_comm + (v_old_salary * 0.02);

    ELSIF ratings = 3 THEN
        v_new_salary := v_old_salary + 2000;
        v_new_bonus  := v_old_bonus;
        v_new_comm   := v_old_comm;

    ELSE
        DBMS_OUTPUT.PUT_LINE('ERROR: Invalid rating level.');
        RETURN;
    END IF;

    -- Update the employee's compensation
    UPDATE EMPLOYEE
    SET SALARY = v_new_salary,
        BONUS = v_new_bonus,
        COMM = v_new_comm
    WHERE EMPNO = emNum;

    -- Display result
    DBMS_OUTPUT.PUT_LINE('EMP: ' || emNum);
    DBMS_OUTPUT.PUT_LINE('OLD SALARY: ' || v_old_salary);
    DBMS_OUTPUT.PUT_LINE('OLD BONUS : ' || v_old_bonus);
    DBMS_OUTPUT.PUT_LINE('OLD COMM  : ' || v_old_comm);
    DBMS_OUTPUT.PUT_LINE('NEW SALARY: ' || v_new_salary);
    DBMS_OUTPUT.PUT_LINE('NEW BONUS : ' || v_new_bonus);
    DBMS_OUTPUT.PUT_LINE('NEW COMM  : ' || v_new_comm);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Employee ' || emNum || ' does not exist.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/


--SELECT * FROM EMPLOYEE;
SET SERVEROUTPUT ON;
BEGIN
    salary('000010', 1);
END;
/
BEGIN
    salary('000020', 2);
END;
/
-- Valid employee with rating 3
BEGIN
    salary('000030', 3);
END;
/

-- Invalid employee
BEGIN
    salary('999999', 2);
END;
/

-- Invalid rating
BEGIN
    salary('000010', 5);
END;
/


-- 2. Write a stored procedure for the EMPLOYEE table
CREATE OR REPLACE PROCEDURE update_edlevel (
    p_empno IN VARCHAR2,
    p_edcode IN CHAR
)
IS
    v_current_edlevel EMPLOYEE.EDLEVEL%TYPE;
    v_new_edlevel     EMPLOYEE.EDLEVEL%TYPE;
BEGIN
    -- Get current education level
    SELECT EDLEVEL INTO v_current_edlevel
    FROM EMPLOYEE
    WHERE EMPNO = p_empno;

    -- Determine new education level based on code
    CASE UPPER(p_edcode)
        WHEN 'H' THEN v_new_edlevel := 16;
        WHEN 'C' THEN v_new_edlevel := 19;
        WHEN 'U' THEN v_new_edlevel := 20;
        WHEN 'M' THEN v_new_edlevel := 23;
        WHEN 'P' THEN v_new_edlevel := 25;
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR: Invalid education code "' || p_edcode || '".');
            RETURN;
    END CASE;

    -- Ensure the new level is not lower than the current one
    IF v_new_edlevel < v_current_edlevel THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Cannot downgrade education level. Current level is ' || v_current_edlevel || '.');
        RETURN;
    END IF;

    -- Perform the update
    UPDATE EMPLOYEE
    SET EDLEVEL = v_new_edlevel
    WHERE EMPNO = p_empno;

    -- Output result
    DBMS_OUTPUT.PUT_LINE('Here is the updated data');
    DBMS_OUTPUT.PUT_LINE('EMP: ' || p_empno);
    DBMS_OUTPUT.PUT_LINE('OLD EDUCATION: ' || v_current_edlevel);
    DBMS_OUTPUT.PUT_LINE('NEW EDUCATION: ' || v_new_edlevel);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Employee ' || p_empno || ' does not exist.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/

SET SERVEROUTPUT ON;
-- 1. Valid upgrade to high school diploma
BEGIN
    update_edlevel('000010', 'H');
END;
/

-- 2. Valid upgrade to college diploma
BEGIN
    update_edlevel('000020', 'C');
END;
/

-- 3. Valid upgrade to university degree
BEGIN
    update_edlevel('000030', 'U');
END;
/


-- 5. Valid upgrade to PhD
BEGIN
    update_edlevel('000060', 'P');
END;
/

-- 6. Invalid education code
BEGIN
    update_edlevel('000070', 'K');
END;
/


-- 3. Write a procedure Customer
 
-- Procedure 1: find_customer
CREATE OR REPLACE PROCEDURE find_customer(
    customer_id IN NUMBER,
    found OUT NUMBER
) IS
    counts NUMBER;
BEGIN
    -- Check if the customer exists in the table
    SELECT count(*) INTO counts
    FROM customers
    WHERE customer_id = find_customer.customer_id;

    found := 1;  -- if the customer is found

    --DBMS_OUTPUT.PUT_LINE('The found customer ID ' || customer_id || ' found.');
    IF counts > 0 THEN
        found := 1;
        DBMS_OUTPUT.PUT_LINE('Customer ID ' || customer_id || ' was found.');
    ELSE
        found := 0;
        DBMS_OUTPUT.PUT_LINE('Customer ID ' || customer_id || ' was NOT found.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        found := 0;
        DBMS_OUTPUT.PUT_LINE('Customer ID ' || customer_id || ' not found.');
    WHEN OTHERS THEN
        found := 0;
        DBMS_OUTPUT.PUT_LINE('Unexpected error occured!');
END;
/

--DESC customers;
SET SERVEROUTPUT ON;
DECLARE
    v_found NUMBER;
BEGIN
    find_customer(177, v_found);
    DBMS_OUTPUT.PUT_LINE('FOUND value returned: ' || v_found);
END;
/

DECLARE
    v_found NUMBER;
BEGIN
    find_customer(9999, v_found); -- Non-existent CUSTOMER_ID
    DBMS_OUTPUT.PUT_LINE('The customer is not FOUND = ' || v_found);
END;
/

-- Procedure 2: find_product
CREATE OR REPLACE PROCEDURE find_product(
    product_id IN NUMBER,
    price OUT products.list_price%TYPE
) IS
BEGIN
    SELECT list_price INTO price
    FROM products
    WHERE product_id = find_product.product_id;

    DBMS_OUTPUT.PUT_LINE('Product ID ' || product_id || ' has a price of $' || price);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        price := 0;
        DBMS_OUTPUT.PUT_LINE('The found product ID ' || product_id || 'has not been found.');
    WHEN OTHERS THEN
        price := 0;
        DBMS_OUTPUT.PUT_LINE('Unexpected error occured!');
END;
/       


SET SERVEROUTPUT ON;
DECLARE
    v_found NUMBER;
BEGIN
    find_product(228, v_found);
    DBMS_OUTPUT.PUT_LINE('FOUND value returned: ' || v_found);
END;
/
DECLARE
    v_price products.list_price%TYPE;
BEGIN
    find_product(9999, v_price); -- Non-existent PRODUCT_ID
    DBMS_OUTPUT.PUT_LINE('Price Returned: ' || v_price);
END;
/



-- Procedure 3: add_order
CREATE OR REPLACE PROCEDURE add_order (
    customer_id IN NUMBER,
    new_order_id OUT NUMBER
) IS
    counts NUMBER := 0;
BEGIN
    -- Check if the customer exists
    SELECT COUNT(*) INTO counts
    FROM customers
    WHERE customer_id = add_order.customer_id;

    IF counts = 0 THEN
        DBMS_OUTPUT.PUT_LINE('The customer ID ' || customer_id || ' does NOT exist. The system cannot create order.');
        new_order_id := NULL;
        RETURN;
    END IF;
    
    -- Find the current max order_id and generate new order ID
    SELECT NVL(MAX(order_id), 0) + 1 INTO new_order_id
    FROM orders;

    -- Insert the new order
    INSERT INTO orders (
        order_id,
        customer_id,
        status,
        salesman_id,
        order_date
    ) VALUES (
        new_order_id,
        customer_id,
        'Shipped',
        56,
        SYSDATE
    );

    DBMS_OUTPUT.PUT_LINE('Order added successfully:');
    DBMS_OUTPUT.PUT_LINE('The new order inserted with ID: ' || new_order_id);
    DBMS_OUTPUT.PUT_LINE('Customer ID: ' || customer_id);
    DBMS_OUTPUT.PUT_LINE('Status: Shipped');
    DBMS_OUTPUT.PUT_LINE('Sales Rep ID: 56');
    DBMS_OUTPUT.PUT_LINE('Order Date: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD'));
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('The unexpected error occurred: ' || customer_id || ': ' || SQLERRM);
        new_order_id := NULL;
END;
/


SET SERVEROUTPUT ON;
DECLARE
    v_new_order_id NUMBER;
BEGIN
    add_order(101, v_new_order_id);
    DBMS_OUTPUT.PUT_LINE('Test Case 1 Passed. New Order ID: ' || v_new_order_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Test Case 1 Failed: ' || SQLERRM);
END;
/

DECLARE
    v_new_order_id NUMBER;
BEGIN
    add_order(997788, v_new_order_id);
    DBMS_OUTPUT.PUT_LINE('Test Case 2 Unexpected Success. New Order ID: ' || v_new_order_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Test Case 2 Passed (Expected Failure): ' || SQLERRM);
END;
/


-- Now check the data inserted
SELECT order_id, customer_id, status, salesman_id, TO_CHAR(order_date, 'YYYY-MM-DD')
FROM orders
WHERE order_id = (SELECT MAX(order_id) FROM orders);



-- Procedure 4: add_order_item
CREATE OR REPLACE PROCEDURE add_order_item(
    orderId IN order_items.order_id%TYPE,
    itemId IN order_items.item_id%TYPE,
    productId IN order_items.product_id%TYPE,
    quantity IN order_items.quantity%TYPE,
    price IN order_items.unit_price%TYPE
) IS
BEGIN
    INSERT INTO order_items(order_id, item_id, product_id, quantity, unit_price)
    VALUES (orderId, itemId, productId, quantity, price);

    -- Output summary message
    DBMS_OUTPUT.PUT_LINE('The new order item added:');
    DBMS_OUTPUT.PUT_LINE('  Order ID:    ' || orderId);
    DBMS_OUTPUT.PUT_LINE('  Item ID:     ' || itemId);
    DBMS_OUTPUT.PUT_LINE('  Product ID:  ' || productId);
    DBMS_OUTPUT.PUT_LINE('  Quantity:    ' || quantity);
    DBMS_OUTPUT.PUT_LINE('  Unit Price:  $' || TO_CHAR(price, '9990.00'));
    DBMS_OUTPUT.PUT_LINE('  Total Cost:  $' || TO_CHAR(quantity * price, '9990.00'));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('The unexpected error adding item: ' || SQLERRM);
END;
/

SET SERVEROUTPUT ON;
BEGIN
    add_order_item(101, 1, 555, 3, 49.99);
END;
/


-- Procedure 5: display_order
CREATE OR REPLACE PROCEDURE display_order(orderId IN NUMBER) IS
    -- Variable to hold customer ID
    v_customer_id orders.customer_id%TYPE;

    -- Cursor to fetch order items
    CURSOR item_cursor IS
        SELECT item_id, product_id, quantity, unit_price
        FROM order_items
        WHERE order_id = orderId;

    -- Record type for cursor
    v_item item_cursor%ROWTYPE;

    -- Total order cost
    v_total_price NUMBER := 0;

    -- Counter to check if any item was found
    v_item_found BOOLEAN := FALSE;

BEGIN
    -- Try to get customer ID to check if order exists
    SELECT customer_id INTO v_customer_id
    FROM orders
    WHERE order_id = orderId;

    -- Print order header
    DBMS_OUTPUT.PUT_LINE('Here is the table of orders given: ');
    DBMS_OUTPUT.PUT_LINE('Order ID: ' || orderId);
    DBMS_OUTPUT.PUT_LINE('Customer ID: ' || v_customer_id);
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Item ID | Product ID | Quantity | Unit Price');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');

    -- Loop through the order items to print out all orders
    FOR v_item IN item_cursor LOOP
        v_item_found := TRUE;
        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_item.item_id, 8) || ' | ' ||
            RPAD(v_item.product_id, 10) || ' | ' ||
            RPAD(v_item.quantity, 8) || ' | ' ||
            TO_CHAR(v_item.unit_price, '9990.00')
        );
        v_total_price := v_total_price + (v_item.quantity * v_item.unit_price);
    END LOOP;

    IF v_item_found THEN
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Total Order Price: $' || TO_CHAR(v_total_price, '999,999.99'));
    ELSE
        DBMS_OUTPUT.PUT_LINE('No items found for this order.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Order ID ' || orderId || ' does NOT exist.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred with Order ID ' || orderId || ': ' || SQLERRM);
END;
/

--SELECT * FROM orders;
SET SERVEROUTPUT ON;

BEGIN
    display_order(101); 
END;
/

-- Procedure 6: master_proc
CREATE OR REPLACE PROCEDURE master_proc(
    task IN NUMBER,
    parm1 IN NUMBER
) IS
    pricePro products.list_price%TYPE;
    foundPro NUMBER;
    new_order NUMBER;
BEGIN
    CASE task
        WHEN 1 THEN
            find_customer(parm1, foundPro);
        WHEN 2 THEN
            find_product(parm1, pricePro);
        WHEN 3 THEN
            add_order(parm1, new_order);
        WHEN 4 THEN
            display_order(parm1);
        ELSE
            DBMS_OUTPUT.PUT_LINE('The unexpected error.');
    END CASE;
END;
/

-- ========================
-- CALL TESTCASE COMMANDS
-- ========================
SET SERVEROUTPUT ON;
-- 1. find_customer – valid
BEGIN master_proc(1, 10); END;
/
-- 2. find_customer – invalid
BEGIN master_proc(1, 9999); END;
/
-- 3. find_product – valid
BEGIN master_proc(2, 2001); END;
/
-- 4. find_product – invalid
BEGIN master_proc(2, 9999); END;
/
-- 5. add_order – valid
BEGIN master_proc(3, 101); END;
/
-- 6. add_order – invalid
BEGIN master_proc(3, 9999); END;
/
-- 7. add_order_item – 5 valid inserts
BEGIN add_order_item(1001, 1, 2001, 2, 19.99); END;
/
BEGIN add_order_item(1001, 2, 2002, 1, 9.50); END;
/
BEGIN add_order_item(1001, 3, 2003, 3, 4.25); END;
/
BEGIN add_order_item(1001, 4, 2004, 5, 15.00); END;
/
BEGIN add_order_item(1001, 5, 2005, 2, 7.75); END;
/
-- 8. add_order_item – invalid order ID
BEGIN add_order_item(9999, 1, 2001, 2, 19.99); END;
/
-- 9. display_order – valid
BEGIN master_proc(4, 106); END;
/
BEGIN master_proc(4, 9999); END;
/
BEGIN master_proc(1, 104); END;
/
BEGIN master_proc(2, 2002); END;
/
BEGIN master_proc(3, 102); END;
/
BEGIN master_proc(4, 1002); END;
/




