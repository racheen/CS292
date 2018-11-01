--------------------------------------------------------
--  File created - Friday-January-26-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure COUNT_TOPOLOGY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "SYSTEM"."COUNT_TOPOLOGY" 
AS 
    product_code COUNT_TABLE.product_code%TYPE;
    max_count number;
    max_row number;
    children_id number;
    parent_id number;
    count_product number;
    current_count number;
    prev_prod_count number;
    min_count number;

BEGIN
    --Count Topology
    EXECUTE IMMEDIATE ('DROP TABLE COUNT_TABLE');

    EXECUTE IMMEDIATE ('CREATE TABLE COUNT_TABLE (
        product_code varchar2(100),
        count_product number
    )');

    EXECUTE IMMEDIATE ('INSERT INTO COUNT_TABLE
        SELECT product_code, count(product_code)
        FROM SAMPLE_RAW
        GROUP BY product_code
        ORDER BY 2');

    EXECUTE IMMEDIATE ('COMMIT');

    execute immediate ('DROP TABLE children_table');
    execute immediate ('CREATE TABLE children_table (
        product_code varchar2(100),
        count_product number,
        children_id number
        )');

    select MAX(count_product) into max_count from COUNT_TABLE;
    select MAX(rownum) into max_row from COUNT_TABLE;
    select MIN(count_product) into min_count from COUNT_TABLE;

    current_count := 1;
    count_product := min_count;
    FOR I IN 1..max_row LOOP
        select product_code, count_product into product_code, count_product
            from (SELECT product_code, count_product, ROWNUM AS RN FROM COUNT_TABLE) 
            where RN = I;
        if count_product != max_count then
            if prev_prod_count != count_product then
                children_id := current_count + 1;
                current_count := current_count + 1;
            else
                children_id := current_count;
            end if;

            execute immediate('INSERT INTO children_table
                (product_code, children_id, count_product)
                VALUES
                ('''||product_code||''','|| children_id ||','|| count_product ||')');
            prev_prod_count := count_product;
        end if;
    END LOOP; 
    children_id := current_count + 1;
    execute immediate('INSERT INTO children_table
                (product_code, children_id, count_product)
                VALUES
                (null,'|| children_id ||', null)');
                
END COUNT_TOPOLOGY;

/
