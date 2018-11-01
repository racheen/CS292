--------------------------------------------------------
--  File created - Friday-January-26-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure CREATE_DIMENSION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "SYSTEM"."CREATE_DIMENSION" AS 
    CURSOR CountTable IS
        SELECT *
        FROM count_table;
        
    ParT Parent_Table%ROWTYPE;
    parent_code varchar2(10);
    lowest_count_product varchar2(10);
    highest_count_product varchar2(10);
    no_children_id varchar2(10);
    no_parent_id varchar2(10);
    max_count_products number;
    min_count_products number;
    sqlqry clob;

    parent_position number;
    product_code COUNT_TABLE.product_code%TYPE;
    max_count number;
    max_row number;
    parent_id number;
    children_id number;
    count_product number;
    previous_max_count number;
    current_count number;
    prev_prod_count number;
    min_count number;
    
    CountT count_table%ROWTYPE;

BEGIN
    EXECUTE IMMEDIATE ('DROP TABLE DIMENSION_TABLE');

    EXECUTE IMMEDIATE ('CREATE TABLE DIMENSION_TABLE(
        product_code VARCHAR2(100),
        product varchar2(10)
        )');

    EXECUTE IMMEDIATE ('INSERT INTO DIMENSION_TABLE
        SELECT product_code, product
        FROM SAMPLE_RAW
        GROUP BY product_code, product
        ORDER BY 1');

    EXECUTE IMMEDIATE ('ALTER TABLE DIMENSION_TABLE
        ADD 
        PARENT_ID varchar2(10)');
    
    OPEN CountTable;
        LOOP
            FETCH CountTable INTO CountT;
            EXIT WHEN CountTable%NOTFOUND;
            EXECUTE IMMEDIATE ('UPDATE DIMENSION_TABLE
                SET PARENT_ID = '||CountT.product_code||' 
                WHERE PRODUCT_CODE = '||CountT.product_code);
        END LOOP;
    CLOSE CountTable;
    
    --INSERT VALUES FOR PARENT_ID
--    OPEN ParentT;
--    LOOP
--        FETCH ParentT INTO ParT;
--        EXIT WHEN ParentT%NOTFOUND;
--        execute immediate ('UPDATE DIMENSION_TABLE
--                SET parent_id = '||ParT.parent_id||'
--                WHERE product_code = '''||ParT.product_code||'''');
--    END LOOP;
--    CLose ParentT;
--    select max(count_product) into max_count_products from COUNT_TABLE;
--    select max(product_code) into highest_count_product
--        from COUNT_TABLE
--        where count_product = max_count_products
--        AND ROWNUM <= 1;
--
--    select max(parent_id) into no_parent_id
--        from PARENT_TABLE;
--
--    execute immediate ('UPDATE DIMENSION_TABLE
--                SET parent_id = '||no_parent_id||'
--                WHERE product_code = '''||highest_count_product||'''');
--
--    execute immediate('select * from dimension_table');
--
--    select MAX(count_product) into max_count from COUNT_TABLE;
--    select MAX(rownum) into max_row from COUNT_TABLE;
--    select MIN(count_product) into min_count from COUNT_TABLE;
--
--    current_count := 1;
--    count_product := min_count;
--
--    FOR I IN 1..max_row LOOP
--
--        select product_code, count_product into product_code, count_product
--            from (SELECT product_code, count_product, ROWNUM AS RN FROM COUNT_TABLE) 
--            where RN = I;
--        if count_product != max_count then
--            if prev_prod_count != count_product then
--                parent_id := current_count + 1;
--                current_count := current_count + 1;
--            else
--                parent_id := current_count;
--            end if;
--            execute immediate ('UPDATE DIMENSION_TABLE
--                SET parent_id ='||parent_id||'
--                WHERE product_code = '||product_code);
--            prev_prod_count := count_product;
--        end if;
--    END LOOP;
--
--    select MAX(count_product) into max_count_products from COUNT_TABLE;
--    select max(product_code) into highest_count_product
--        from COUNT_TABLE
--        where count_product = max_count_products
--        AND ROWNUM <= 1;
--
--    select max(parent_id) into no_parent_id
--        from PARENT_TABLE;
--
--    sqlqry := 'UPDATE DIMENSION_TABLE
--                SET parent_id = '||no_parent_id||'
--                WHERE parent_id = -1';
--    execute immediate (sqlqry);
--
--    current_count := 1;
--    count_product := min_count;
--
--    prev_prod_count := null;
--
--    --INSERT VALUES FOR CHILDREN_ID
--    FOR I IN 1..max_row LOOP
--
--        select product_code, count_product into product_code, count_product
--            from (SELECT product_code, count_product, ROWNUM AS RN FROM COUNT_TABLE) 
--            where RN = I;
--
--        if count_product != min_count then
--            if prev_prod_count != count_product then
--                children_id := current_count + 1;
--                current_count := current_count + 1;
--            else
--                children_id := current_count;
--            end if;
--            execute immediate ('UPDATE DIMENSION_TABLE
--                SET children_id ='''||children_id||'''
--                WHERE product_code = '''||product_code||'''');
--            prev_prod_count := count_product;
--        end if;
--    END LOOP;
--
--    select MIN(count_product) into min_count_products from COUNT_TABLE;
--    select product_code into lowest_count_product
--        from COUNT_TABLE
--        where count_product = min_count_products
--        AND ROWNUM <= 1;
--
--    select max(children_id) into no_children_id
--        from CHILDREN_TABLE;
--
--    sqlqry := 'UPDATE DIMENSION_TABLE
--                SET children_id = '||no_children_id||'
--                WHERE children_id = -1';
--    execute immediate (sqlqry);
    EXECUTE IMMEDIATE ('ALTER TABLE DIMENSION_TABLE
        ADD Parent_Count number
    ');
END CREATE_DIMENSION;

/
