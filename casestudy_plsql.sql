set serveroutput on;

-- Create the tables

CREATE TABLE customers (
    customer_id  NUMBER PRIMARY KEY,
    first_name   VARCHAR2(50),
    last_name    VARCHAR2(50),
    email        VARCHAR2(100),
    phone_number NUMBER,
    address      VARCHAR2(200)
);

CREATE TABLE cars (
    car_id         NUMBER PRIMARY KEY,
    make           VARCHAR2(50),
    model          VARCHAR2(50),
    year           NUMBER,
    color          VARCHAR2(50),
    price          NUMBER,
    purchase_count NUMBER
);

CREATE TABLE purchases (
    purchase_id   NUMBER PRIMARY KEY,
    customer_id   NUMBER
        REFERENCES customers ( customer_id ),
    car_id        NUMBER
        REFERENCES cars ( car_id ),
    purchase_date DATE,
    total_amount  NUMBER
);

--Insert values into customers table

INSERT INTO customers VALUES (
    1,
    'priyanka',
    'jena',
    'abc@gmail.com',
    6370574749,
    'abcd'
);

INSERT INTO customers VALUES (
    2,
    'rimsy',
    'swain',
    'efg@gmail.com',
    7976197635,
    'dffda'
);

INSERT INTO customers VALUES (
    3,
    'sonika',
    'sahoo',
    'sdf@gmail.com',
    9437210987,
    'hunn'
);

INSERT INTO customers VALUES (
    4,
    'sarada',
    'pradhan',
    'hgn@gmail.com',
    6370564789,
    'lsjd'
);

INSERT INTO customers VALUES (
    5,
    'sambit',
    'tripathy',
    'sam@gmail.com',
    9238581335,
    'rgdsa'
);

--Insert values into cars table

INSERT INTO cars VALUES (
    1,
    'Jaguar',
    'E-PACE',
    2000,
    'Silver',
    5000000,
    10
);

INSERT INTO cars VALUES (
    2,
    'Audi',
    'Q7',
    2007,
    'White',
    3000000,
    5
);

INSERT INTO cars VALUES (
    3,
    'Mercedes-Benz',
    'A-Class',
    2020,
    'Red',
    7000000,
    2
);

INSERT INTO cars VALUES (
    4,
    'Honda',
    'City',
    2013,
    'Black',
    2000000,
    10
);

INSERT INTO cars VALUES (
    5,
    'Kia',
    'Forte',
    2021,
    'White',
    2300000,
    28
);

-- Insert values into purchases table

INSERT INTO purchases VALUES (
    1,
    2,
    4,
    TO_DATE('2023-03-23', 'YYYY-MM-DD'),
    2000000
);

INSERT INTO purchases VALUES (
    2,
    1,
    2,
    TO_DATE('2020-05-09', 'YYYY-MM-DD'),
    3000000
);

INSERT INTO purchases VALUES (
    3,
    3,
    2,
    TO_DATE('2020-05-10', 'YYYY-MM-DD'),
    3000000
);

INSERT INTO purchases VALUES (
    4,
    4,
    3,
    TO_DATE('2018-11-18', 'YYYY-MM-DD'),
    7000000
);

INSERT INTO purchases VALUES (
    5,
    5,
    3,
    TO_DATE('2022-08-09', 'YYYY-MM-DD'),
    7000000
);

-- Procedure to insert a new customer into customers table

CREATE OR REPLACE PROCEDURE register_customer (
    customer_id    IN NUMBER,
    p_first_name   IN VARCHAR2,
    p_last_name    IN VARCHAR2,
    p_email        IN VARCHAR2,
    p_phone_number IN NUMBER,
    p_address      IN VARCHAR2
) IS
BEGIN
    INSERT INTO customers (
        customer_id,
        first_name,
        last_name,
        email,
        phone_number,
        address
    ) VALUES (
        customer_id,
        p_first_name,
        p_last_name,
        p_email,
        p_phone_number,
        p_address
    );

    COMMIT;
END register_customer;

--Calling the procedure with parameters

BEGIN
    register_customer(8, 'Priyansh', 'Jena', 'ggg@gmail.com', 9437209789,
                     'gfchfcmdza');
END;

-- Get the table customers

SELECT
    *
FROM
    customers;

-- Get the table purchases

SELECT
    *
FROM
    purchases;
    
-- Get the table cars

SELECT
    *
FROM
    cars;

-- Trigger to update the purchase_count column when there is a new purchase

CREATE OR REPLACE TRIGGER update_purchase_count AFTER
    INSERT ON purchases
    FOR EACH ROW
BEGIN
    UPDATE cars
    SET
        purchase_count = purchase_count + 1
    WHERE
        car_id = :new.car_id;

END update_purchase_count;

-- Insert into Purchases to check functioning of trigger

INSERT INTO purchases VALUES (
    14,
    5,
    4,
    TO_DATE('2020-05-09', 'YYYY-MM-DD'),
    7000000
);



-- Cursor to retrieve data

DECLARE
    CURSOR purchase_cursor IS
    SELECT
        p.purchase_id,
        c.first_name,
        c.last_name,
        ca.make,
        ca.model,
        p.total_amount
    FROM
        purchases p
        JOIN customers c ON p.customer_id = c.customer_id
        JOIN cars ca ON p.car_id = ca.car_id
    ORDER BY
        p.purchase_id;

    v_purchase_id  purchases.purchase_id%TYPE := 12;
    v_first_name   customers.first_name%TYPE;
    v_last_name    customers.last_name%TYPE;
    v_make         cars.make%TYPE;
    v_model        cars.model%TYPE;
    v_total_amount purchases.total_amount%TYPE;
BEGIN
    OPEN purchase_cursor;
    LOOP
        FETCH purchase_cursor INTO
            v_purchase_id,
            v_first_name,
            v_last_name,
            v_make,
            v_model,
            v_total_amount;
        EXIT WHEN purchase_cursor%notfound;
        dbms_output.put_line('Purchase Id:' || v_purchase_id);
        dbms_output.put_line('Customer:'
                             || v_first_name
                             || ' '
                             || v_last_name);
        dbms_output.put_line('Car:'
                             || v_make
                             || ' '
                             || v_model);
        dbms_output.put_line('Total Amount:$' || v_total_amount);
    END LOOP;

    CLOSE purchase_cursor;
END purchase_cursor;

-- Function to get the total purchase amount of a car in a specific month  

CREATE OR REPLACE FUNCTION get_total_purchase_amount (
    car_id IN NUMBER,
    month  IN NUMBER,
    year   IN NUMBER
) RETURN NUMBER IS
    total_amount NUMBER := 0;
BEGIN
    SELECT
        SUM(total_amount)
    INTO total_amount
    FROM
        purchases
    WHERE
            car_id = car_id
        AND EXTRACT(MONTH FROM purchase_date) = month
        AND EXTRACT(YEAR FROM purchase_date) = year;

    RETURN total_amount;
EXCEPTION
    WHEN no_data_found THEN
        RETURN 0;
END;

-- Calling the function with parameters

DECLARE
    x NUMBER;
BEGIN
    x := get_total_purchase_amount(2, 5, 2020);
    dbms_output.put_line(x);
END;

-- Package containing procedure and function
-- Package specification

CREATE OR REPLACE PACKAGE car_mgmt_package AS
PROCEDURE register_customer (
        customer_id    IN NUMBER,
        p_first_name   IN VARCHAR2,
        p_last_name    IN VARCHAR2,
        p_email        IN VARCHAR2,
        p_phone_number IN NUMBER,
        p_address      IN VARCHAR2
    );

    FUNCTION get_total_purchase_amount (
        car_id IN NUMBER,
        month  IN NUMBER,
        year   IN NUMBER
    ) RETURN NUMBER;

END car_mgmt_package;

-- Package body

CREATE OR REPLACE PACKAGE BODY car_mgmt_package AS

-- Procedure to insert new customer

PROCEDURE register_customer (
    customer_id    IN NUMBER,
    p_first_name   IN VARCHAR2,
    p_last_name    IN VARCHAR2,
    p_email        IN VARCHAR2,
    p_phone_number IN NUMBER,
    p_address      IN VARCHAR2
) AS
BEGIN
    INSERT INTO customers (
        customer_id,
        first_name,
        last_name,
        email,
        phone_number,
        address
    ) VALUES (
        customer_id,
        p_first_name,
        p_last_name,
        p_email,
        p_phone_number,
        p_address
    );

    COMMIT;
END register_customer;

-- Funtion to get total purchase amount of a car in specific month

FUNCTION get_total_purchase_amount (
    car_id IN NUMBER,
    month  IN NUMBER,
    year   IN NUMBER
) RETURN NUMBER IS
    total_amount NUMBER := 0;
BEGIN
    SELECT
        SUM(total_amount)
    INTO total_amount
    FROM
        purchases
    WHERE
            car_id = car_id
        AND EXTRACT(MONTH FROM purchase_date) = month
        AND EXTRACT(YEAR FROM purchase_date) = year;

    RETURN total_amount;
EXCEPTION
    WHEN no_data_found THEN
        RETURN 0;
END get_total_purchase_amount;
END car_mgmt_package;

-- Calling function of package 

DECLARE
    res NUMBER;
BEGIN
    res := car_mgmt_package.get_total_purchase_amount(2, 5, 2020);
    dbms_output.put_line(res);
END;
SELECT * FROM cars;

--create an exception handler which handles the incorrect date 
CREATE OR REPLACE PROCEDURE get_date
(
p_purchase_date IN DATE
)
as
correct_date EXCEPTION;
BEGIN
If p_purchase_date <= '01-JAN-2018' THEN
RAISE correct_date;
END IF;

EXCEPTION
WHEN correct_date THEN
dbms_output.put_line('Enter correct date');
WHEN OTHERS THEN 
dbms_output.put_line('Error occured');
END;

execute get_date('14-FEB-2017');
