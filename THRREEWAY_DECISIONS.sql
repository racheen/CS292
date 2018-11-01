--------------------------------------------------------
--  File created - Friday-January-26-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure THREEWAY_DECISIONS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "SYSTEM"."THREEWAY_DECISIONS" AS 
     max_probability number;
    min_probability number;
    avg_probability number;
    product_code COUNT_TABLE.product_code%TYPE;
    prob number;
    max_row number;
    prods varchar2(100);
    
BEGIN
    execute immediate ('DROP TABLE THREEWAY_TABLE');
    execute immediate ('CREATE TABLE THREEWAY_TABLE (
        alpha number,
        beta number,
        theta number
        )');
    execute immediate ('DELETE FREQUENCY_T');
--    execute immediate ('CREATE TABLE FREQUENT_TABLE (
--        products varchar2(100),
--        probability number
--        )');
--    
--    execute immediate ('DROP TABLE NEUTRAL_TABLE');
--    execute immediate ('CREATE TABLE NEUTRAL_TABLE (
--        products varchar2(100),
--        probability number
--        )');
--        
    execute immediate ('DELETE NONFREQUENT_TABLE');
--    execute immediate ('CREATE TABLE NONFREQUENT_TABLE (
--        products varchar2(100),
--        probability number
--        )');
        
    select MAX(frequency) into max_probability from pivot_table3;
    select MIN(frequency) into min_probability from pivot_table3;
    select AVG(frequency) into avg_probability from pivot_table3;
    execute immediate('INSERT INTO THREEWAY_TABLE
        (alpha, beta, theta)
         VALUES
         ('||max_probability||','||avg_probability||','||min_probability||')'); 
            
    execute immediate ('INSERT INTO FREQUENCY_T
        SELECT * FROM pivot_table3 
        WHERE frequency <='||max_probability||'AND frequency >'||avg_probability);
--     execute immediate ('INSERT INTO NEUTRAL_TABLE
--        SELECT * FROM CPT_P 
--        WHERE PROBABILITY <='||avg_probability||'AND PROBABILITY >'||min_probability);
--     execute immediate ('INSERT INTO NONFREQUENT_TABLE
--        SELECT * FROM pivot_table3 
--        WHERE frequency >='||min_probability||'AND frequency <'||avg_probability);
        
--    execute immediate ('UPDATE NONFREQUENT_TABLE
--        SET FREQUENCY = 1');   
    execute immediate ('UPDATE FREQUENCY_T
        SET FREQUENCY = 0');
END THREEWAY_DECISIONS;

/
