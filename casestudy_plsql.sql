SET SERVEROUTPUT ON;




--creating tables

CREATE TABLE contractors (
    contractor_id   NUMBER PRIMARY KEY,
    contractor_name VARCHAR2(100) NOT NULL,
    phone_number    VARCHAR2(20),
    email           VARCHAR2(100)
);

CREATE TABLE home_projects (
    project_id       NUMBER PRIMARY KEY,
    project_name     VARCHAR2(100) NOT NULL,
    project_status   VARCHAR2(50),
    available_houses NUMBER,
    contractor_id    NUMBER
        REFERENCES contractors ( contractor_id )
);

CREATE TABLE sales (
    sale_id    NUMBER PRIMARY KEY,
    project_id NUMBER
        REFERENCES home_projects ( project_id ),
    amount     NUMBER(10, 2),
    sale_date  DATE
);







-- inserting values into the  contractors table

INSERT INTO contractors VALUES (
    1,
    'John',
    6379769834,
    'john@gmail.com'
);

INSERT INTO contractors VALUES (
    2,
    'Simi',
    9875302356,
    'simran5@yahoo.com'
);

INSERT INTO contractors VALUES (
    3,
    'Trisha',
    8567788931,
    'tri67sha@gmail.com'
);

INSERT INTO contractors VALUES (
    4,
    'Kevin',
    7234594500,
    'kev97@yahoo.com'
);

INSERT INTO contractors VALUES (
    5,
    'Cipher',
    9776540412,
    'ciph19@gmail.com'
);

SELECT
    *
FROM
    contractors;
    
    
    
    
    
    
    

-- inserting values into the home_projects table

INSERT INTO home_projects VALUES (
    1,
    'Project A',
    'In Progress',
    5,
    1
);

INSERT INTO home_projects VALUES (
    2,
    'Project B',
    'Completed',
    0,
    3
);

INSERT INTO home_projects VALUES (
    3,
    'Project C',
    'In Progress',
    3,
    1
);

INSERT INTO home_projects VALUES (
    4,
    'Project D',
    'In Progress',
    2,
    2
);

INSERT INTO home_projects VALUES (
    5,
    'Project E',
    'Completed',
    4,
    5
);

INSERT INTO home_projects VALUES (
    6,
    'Project F',
    'In Progress',
    1,
    1
);

INSERT INTO home_projects VALUES (
    7,
    'Project G',
    'Completed',
    0,
    4
);

INSERT INTO home_projects VALUES (
    8,
    'Project H',
    'Completed',
    3,
    2
);

SELECT
    *
FROM
    home_projects;
    
    
    
    
    
    

-- inserting values into the sales table

INSERT INTO sales VALUES (
    1,
    3,
    208000,
    TO_DATE('2022-04-12', 'YYYY-MM-DD')
);

INSERT INTO sales VALUES (
    2,
    1,
    117000,
    TO_DATE('2022-05-09', 'YYYY-MM-DD')
);

INSERT INTO sales VALUES (
    3,
    1,
    250000,
    TO_DATE('2022-05-14', 'YYYY-MM-DD')
);

INSERT INTO sales VALUES (
    4,
    6,
    380000,
    TO_DATE('2022-06-22', 'YYYY-MM-DD')
);

INSERT INTO sales VALUES (
    5,
    4,
    150600,
    TO_DATE('2022-07-27', 'YYYY-MM-DD')
);

INSERT INTO sales VALUES (
    6,
    7,
    260000,
    TO_DATE('2022-09-02', 'YYYY-MM-DD')
);

INSERT INTO sales VALUES (
    7,
    2,
    190000,
    TO_DATE('2022-11-17', 'YYYY-MM-DD')
);

INSERT INTO sales VALUES (
    8,
    5,
    220000,
    TO_DATE('2023-01-18', 'YYYY-MM-DD')
);

INSERT INTO sales VALUES (
    9,
    2,
    235000,
    TO_DATE('2023-03-10', 'YYYY-MM-DD')
);

SELECT
    *
FROM
    sales;











-- procedure to update the email address of a specific contractor

CREATE OR REPLACE PROCEDURE update_email (
    p_contractor_id IN NUMBER,
    p_new_mail      IN VARCHAR2
) AS
BEGIN
    UPDATE contractors
    SET
        email = p_new_mail
    WHERE
        contractor_id = p_contractor_id;

    COMMIT;
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Contractor Not Found !!');
    WHEN OTHERS THEN
        ROLLBACK;
        dbms_output.put_line('Error : ' || sqlerrm);
END update_email;


-- call the Procedure

BEGIN
    update_email(1, 'deepak@gmail.com');
END;











-- update the availability of houses in the home_projects table when a sale is made

CREATE OR REPLACE TRIGGER update_availability AFTER
    INSERT ON sales
    FOR EACH ROW
DECLARE
    v_project_id home_projects.project_id%TYPE;
BEGIN
    v_project_id := :new.project_id;
    DECLARE
        v_available_houses NUMBER;
    BEGIN
        SELECT
            available_houses
        INTO v_available_houses
        FROM
            home_projects
        WHERE
            project_id = v_project_id;

        IF v_available_houses <= 0 THEN
            dbms_output.put_line('Houses are not available !!');
            ROLLBACK;
        END IF;
    END;

    UPDATE home_projects
    SET
        available_houses = available_houses - 1
    WHERE
        project_id = v_project_id;
    
    --COMMIT;

END;


-- To invoke Trigger

INSERT INTO sales VALUES (
    14,
    1,
    120500,
    TO_DATE('2023-03-05', 'YYYY-MM-DD')
);












-- function calculate the total sales amount for a specific project

CREATE OR REPLACE FUNCTION calculate_total_sales (
    p_project_id IN NUMBER
) RETURN NUMBER AS
    total_amount NUMBER := 0;
BEGIN
    SELECT
        SUM(amount)
    INTO total_amount
    FROM
        sales
    WHERE
        project_id = p_project_id;

    RETURN total_amount;
END;



-- call the function

DECLARE
    total_sales_amt NUMBER;
    t_id            NUMBER;
BEGIN
    t_id := 5;
    total_sales_amt := calculate_total_sales(t_id);
    dbms_output.put_line('Total sales amount for project '
                         || t_id
                         || ': '
                         || total_sales_amt);
END;














-- cursor to retrieve the list of projects for a specific contractor

DECLARE
    v_cont_id        contractors.contractor_id%TYPE := 2;
    v_project_name   home_projects.project_name%TYPE;
    v_project_status home_projects.project_status%TYPE;
    CURSOR c_projects IS
    SELECT
        project_name,
        project_status
    FROM
        home_projects
    WHERE
        contractor_id = v_cont_id;

BEGIN
    OPEN c_projects;
    dbms_output.put_line('Project Details for Contractor ID : ' || v_cont_id);
    dbms_output.put_line('-----------------------------------------------------------');
    LOOP
        FETCH c_projects INTO
            v_project_name,
            v_project_status;
        EXIT WHEN c_projects%notfound;
        dbms_output.put_line('');
        dbms_output.put_line('Project Name : ' || v_project_name);
        dbms_output.put_line('Project Status : ' || v_project_status);
    END LOOP;

    CLOSE c_projects;
END;














-- Package binding both the procedure and function

CREATE OR REPLACE PACKAGE house_selling_pkg AS
    PROCEDURE update_email (
        p_contractor_id IN NUMBER,
        p_new_mail      IN VARCHAR2
    );

    FUNCTION calculate_total_sales (
        p_project_id IN NUMBER
    ) RETURN NUMBER;

END house_selling_pkg;



-- Package Body

CREATE OR REPLACE PACKAGE BODY house_selling_pkg AS

    PROCEDURE update_email (
        p_contractor_id IN NUMBER,
        p_new_mail      IN VARCHAR2
    ) AS
    BEGIN
        UPDATE contractors
        SET
            email = p_new_mail
        WHERE
            contractor_id = p_contractor_id;

        COMMIT;
    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('Contractor Not Found !!');
        WHEN OTHERS THEN
            ROLLBACK;
            dbms_output.put_line('Error : ' || sqlerrm);
    END update_email;

    FUNCTION calculate_total_sales (
        p_project_id IN NUMBER
    ) RETURN NUMBER AS
        total_amount NUMBER := 0;
    BEGIN
        SELECT
            SUM(amount)
        INTO total_amount
        FROM
            sales
        WHERE
            project_id = p_project_id;

        RETURN total_amount;
    END calculate_total_sales;

END house_selling_pkg;


-- calling the procedure
BEGIN
    house_selling_pkg.update_email(2, 'priya23@gmail.com');
END;


--calling the function
DECLARE
    total_sales_amt NUMBER;
    t_id            NUMBER;
BEGIN
    t_id := 2;
    total_sales_amt := house_selling_pkg.calculate_total_sales(t_id);
    dbms_output.put_line('Total sales amount for project '
                         || t_id
                         || ': '
                         || total_sales_amt);
END;










/*
INSERT INTO contractors(contractor_id,contractor_name,phone_number,email)
WITH names AS (
    SELECT 1,'John',6379769834,'john@gmail.com' FROM dual UNION ALL
    SELECT 2,'Simi',9875302356,'simran5@yahoo.com' FROM dual UNION ALL
    SELECT 3,'Trisha',8567788931,'tri67sha@gmail.com' FROM dual UNION ALL
    SELECT 4,'Kevin',7234594500,'kev97@yahoo.com' FROM dual UNION ALL
    SELECT 5,'Cipher',9776540412,'ciph19@gmail.com' FROM dual
)

DELETE FROM contractors WHERE contractor_id=5;

*/


--DELETE FROM sales WHERE sale_id > 8;

/*
UPDATE home_projects
SET available_houses = 5
WHERE project_id = 2 ;
*/

/*
-- handle an exception when inserting a new sales record with an invalid project id
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Project ID Not Found !!');
    WHEN OTHERS THEN
        --ROLLBACK;
        dbms_output.put_line('An error occurred !!'); */


/*

SELECT * FROM home_projects;
SELECT * FROM sales;
*/