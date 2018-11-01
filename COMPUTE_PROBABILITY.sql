--------------------------------------------------------
--  File created - Friday-January-26-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure COMPUTE_PROBABILITY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "SYSTEM"."COMPUTE_PROBABILITY" AS
    
    CURSOR Probabilities IS
        SELECT *
        FROM probability_table;
        
    prob_row probability_table%ROWTYPE;
           
    ProductCode  dimension_table.product_code%TYPE;
    transaction_count number;
    probability number;
    max_transaction number;
    max_row number;
    product_code COUNT_TABLE.product_code%TYPE;
    
    max_probability number;
    min_probability number;
    avg_probability number;
    x number;
    
BEGIN
    execute immediate ('DROP TABLE PROBABILITY_TABLE');
    execute immediate ('CREATE TABLE PROBABILITY_TABLE (
        product_code varchar2(100),
        probability number
        )');
        
    select count(distinct invoice_no) into max_transaction from SAMPLE_RAW;
    select MAX(rownum) into max_row from COUNT_TABLE;
    
--    FOR I IN 1..max_row 
    x := 0;
    LOOP
        x := x + 1;
        exit when (x = max_row);
        select product_code, count_product into product_code, transaction_count 
            from (SELECT product_code, count_product, ROWNUM AS RN FROM COUNT_TABLE) 
            where RN = x;
        
        probability := transaction_count / max_transaction;
        
        execute immediate('INSERT INTO PROBABILITY_TABLE
            (product_code, probability)
            VALUES
            ('''||product_code||''','|| probability ||')
            ');
    END LOOP; 
--    execute immediate ('DROP TABLE THREEWAY_TABLE');
--    execute immediate ('CREATE TABLE THREEWAY_TABLE (
--        alpha number,
--        beta number,
--        theta number
--        )');
--    select MAX(probability) into max_probability from PROBABILITY_TABLE;
--    select MIN(probability) into min_probability from PROBABILITY_TABLE;
--    select AVG(probability) into avg_probability from PROBABILITY_TABLE;
--    execute immediate('INSERT INTO THREEWAY_TABLE
--        (alpha, beta, theta)
--         VALUES
--         ('||max_probability||','||avg_probability||','||min_probability||')
--         '); 
--    OPEN Probabilities;
--    LOOP
--        FETCH Probabilities INTO prob_row;
--        EXIT WHEN Probabilities%NOTFOUND;
--        IF prob_row.probability < min_probability THEN
--            EXECUTE IMMEDIATE ('DELETE FROM DIMENSION_TABLE
--                WHERE product_code = "'||prob_row.product_code||'"
--            ');
--            EXECUTE IMMEDIATE ('DELETE FROM PROBABILITY_TABLE
--                WHERE product_code = "'||prob_row.product_code||'"
--            ');
--            EXECUTE IMMEDIATE ('DELETE FROM sample_raw
--                WHERE product_code = "'||prob_row.product_code||'"
--            ');
--            EXECUTE IMMEDIATE ('DELETE FROM count_table
--                WHERE product_code = "'||prob_row.product_code||'"
--            ');
--            EXECUTE IMMEDIATE ('DELETE FROM parent_Table
--                WHERE product_code = "'||prob_row.product_code||'"
--            ');
--            EXECUTE IMMEDIATE ('DELETE FROM children_Table
--                WHERE product_code = "'||prob_row.product_code||'"
--            ');
--        END IF;
--    END LOOP;
--    CLOSE Probabilities;
    
END COMPUTE_PROBABILITY;

/
