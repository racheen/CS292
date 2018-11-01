--------------------------------------------------------
--  File created - Friday-January-26-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure RESET_PARENT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "SYSTEM"."RESET_PARENT" AS 
    CURSOR CountT1 IS
        SELECT * 
        FROM COUNT_TABLE;
      
    CURSOR CountT2(ProductCode  dimension_table.product_code%TYPE) IS
        SELECT * 
        FROM COUNT_TABLE;
        
    ProductCode  COUNT_TABLE.product_code%TYPE;
    
    parent_position number;
    product_code COUNT_TABLE.product_code%TYPE;
    max_count number;
    max_row number;
    parent_id number;
    count_product number;
    previous_max_count number;
    current_count number;
    prev_prod_count number;
    min_count number;
    
    cou COUNT_TABLE%ROWTYPE;
    
BEGIN
    execute immediate ('DROP TABLE PARENT_TABLE');
    execute immediate ('CREATE TABLE PARENT_TABLE (
        product_code varchar2(100),
        count_product number,
        parent_id number
        )');
        
    select MAX(count_product) into max_count from COUNT_TABLE;
    select MAX(rownum) into max_row from COUNT_TABLE;
    select MIN(count_product) into min_count from COUNT_TABLE;
--
--    OPEN CountT1;
--    FETCH CountT1 INTO cou;
--    current_count := cou.count_product;
--    parent_id := 0;
--    LOOP
--        EXIT WHEN CountT1%NOTFOUND;
--        IF current_count = min_count THEN
--            parent_id := 1;
--            execute immediate('INSERT INTO PARENT_TABLE
--                (product_code, parent_id, count_product)
--                VALUES
--                (null, 1, null)');
--        ELSIF cou.count_product = current_count THEN
--            execute immediate('INSERT INTO PARENT_TABLE
--                (product_code, parent_id, count_product)
--                VALUES
--                ('''||cou.product_code||''','|| parent_id ||','|| cou.count_product ||')');
--        ELSE
--            parent_id := parent_id + 1;
--            execute immediate('INSERT INTO PARENT_TABLE
--                (product_code, parent_id, count_product)
--                VALUES
--                ('''||cou.product_code||''','|| parent_id ||','|| cou.count_product ||')');
--        END IF;
--        current_count := cou.count_product;
--        FETCH CountT1 INTO cou;
--    END LOOP;
--    CLOSE CountT1;

    current_count := 1;
    count_product := min_count;
    FOR I IN 1..max_row LOOP
        
        select product_code, count_product into product_code, count_product
            from (SELECT product_code, count_product, ROWNUM AS RN FROM COUNT_TABLE) 
            where RN = I;
        if count_product != min_count then
            if prev_prod_count != count_product then
                parent_id := current_count + 1;
                current_count := current_count + 1;
            else
                parent_id := current_count;
            end if;
                    
            execute immediate('INSERT INTO PARENT_TABLE
                (product_code, parent_id, count_product)
                VALUES
                ('''||product_code||''','|| parent_id ||','|| count_product ||')');
            prev_prod_count := count_product;
        end if;
    END LOOP; 
    parent_id := current_count + 1;
    execute immediate('INSERT INTO PARENT_TABLE
                (product_code, parent_id, count_product)
                VALUES
                (null,'|| parent_id ||', null)');

END RESET_PARENT;

/
