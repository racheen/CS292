--------------------------------------------------------
--  File created - Friday-January-26-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure CREATE_CPT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "SYSTEM"."CREATE_CPT" AS 
    CURSOR Dimensions IS
        SELECT *
        FROM dimension_table;
        
     CURSOR Dimensions1 IS
        SELECT *
        FROM dimension_table;
            
    CURSOR Dimensions2(ProductCode  dimension_table.product_code%TYPE) IS
        SELECT *
        FROM dimension_table
        WHERE product_code = ProductCode;
    
    CURSOR Parents(ParentCode dimension_table.parent_id%TYPE) IS
        SELECT *
        FROM parent_table
        WHERE (parent_id = ParentCode);
    
    CURSOR Pivots(ProductCode dimension_table.product_code%TYPE) IS
        SELECT *
        FROM pivot_table
        WHERE (product_code = ProductCode);
    
    CURSOR Probabilities(ProductCode  dimension_table.product_code%TYPE) IS
        SELECT *
        FROM probability_table
        WHERE product_code = ProductCode;
        
    CURSOR CountProd(ProductCode dimension_table.product_code%TYPE) IS
        SELECT count_product
        FROM count_table
        WHERE product_code = ProductCode;
     --Declare the table
    TYPE PivotsSSNarray
        IS TABLE OF pivot_table%ROWTYPE
        INDEX BY SIMPLE_INTEGER;
    
    --Declare variables using the table
    PivotsList  PivotsSSNarray;
    
    prob_row probability_table%ROWTYPE;
    dim dimension_table%ROWTYPE;
    parent_row parent_table%ROWTYPE;
    piv pivot_table%ROWTYPE;
    prob probability_table%ROWTYPE;
    par parent_table%ROWTYPE;
    dim2 dimension_table%ROWTYPE;
    
    ParentCode dimension_table.parent_id%TYPE;
    ProductCode  dimension_table.product_code%TYPE;
    
    number_products number;
    parents_count number;
    opposite number;
    confidence number;
    support number;
    lift number;
    MaxRows number;
    CountNumber number;
    counter number := 1;
    counter2 number := 0;
    counter1 number := 0;
    counter0 number := 0;
    countern number := 2;
    countermax number;
    kk number;
    kkk number;
    chck number := 0;
    maxrow number;
    pro number := 1;
    maxtransact number;
    numtransact number;
    CheckSum number;
    counting number := 0;
    cProd number;
    
    ccol clob;
    ToInsert clob;
    condition varchar2(500);
    parentsL varchar2(100);
    parentsList varchar2(100);
    
BEGIN
--    EXECUTE IMMEDIATE ('DROP TABLE CPT_P');
    EXECUTE IMMEDIATE ('CREATE TABLE CPT_P (products varchar2(100), confidence number, support number, lift number)');
    EXECUTE IMMEDIATE ('DROP TABLE sum_table');
    EXECUTE IMMEDIATE ('create table sum_table (summation number)');
    EXECUTE IMMEDIATE ('DROP TABLE sum_table1');
    EXECUTE IMMEDIATE ('create table sum_table1 (summation number)');
    EXECUTE IMMEDIATE ('DROP TABLE sum_table2');
    EXECUTE IMMEDIATE ('create table sum_table2 (summation number)');
    EXECUTE IMMEDIATE ('DROP TABLE check_sum');
    EXECUTE IMMEDIATE ('create table check_sum (sum_transact number)');
    EXECUTE IMMEDIATE ('DROP TABLE check_table');
    EXECUTE IMMEDIATE ('create table check_table (outp number)');
    
    SELECT MAX(invoice_no) INTO maxtransact 
        FROM sample_raw;
    SELECT COUNT(product) INTO number_products 
        FROM dimension_table; 
    --count parents
    OPEN Dimensions;
    LOOP
        FETCH Dimensions INTO dim;
        EXIT WHEN Dimensions%NOTFOUND;
        ParentCode := dim.parent_id;
        OPEN Parents(ParentCode);
        parents_count := 0;
        --count parents
        LOOP
            FETCH Parents INTO parent_row;
            EXIT WHEN Parents%NOTFOUND;
            ProductCode := parent_row.product_code;
            dbms_output.put_line('For ParentID: '||ParentCode);
            dbms_output.put_line('For ProductCode: '||ProductCode);
            OPEN Pivots(ProductCode);
            LOOP
                FETCH Pivots INTO PivotsList(counter);
                EXIT WHEN Pivots%NOTFOUND;
                IF parent_row.product_code = NULL THEN
                    parents_count := 0;
                ELSE
                    parents_count := parents_count + 1;
                END IF;
--                dbms_output.put_line('For Parent ID: '||ParentCode||' product code is '||PivotsList(counter).product_code);
            END LOOP;
--            dbms_output.put_line('parent count = ' || parents_count);
            CLOSE Pivots;
            counter := counter + 1;
        END LOOP;        
        CLOSE Parents;       
        dbms_output.put_line('Parent Count for Code: '||ParentCode||' is '||parents_count);
        OPEN Probabilities(dim.product_code);
        FETCH Probabilities INTO prob_row;
--        execute immediate ('DROP TABLE CPT_'||dim.product_code);
        IF parents_count = 0 THEN
            execute immediate ('CREATE TABLE CPT_'||dim.product_code||'(
                '||dim.product||' varchar2(5),
                probability number,
                rownumber number
            )');
            opposite := 1 -  prob_row.probability;
            execute immediate ('INSERT INTO CPT_'||dim.product_code||'
                VALUES (''0'','||opposite||',1)
            ');
            execute immediate ('INSERT INTO CPT_'||dim.product_code||'
                VALUES (''1'','||prob_row.probability||',2)
            ');
            IF prob_row.probability != 0 THEN
                EXECUTE IMMEDIATE ('INSERT INTO cpt_p VALUES('''||dim.product||''', '||prob_row.probability||', '||prob_row.probability||', '||prob_row.probability||')');
            END IF;
        ELSE
            ParentCode := dim.parent_id;
            OPEN Parents(ParentCode);
            FETCH Parents INTO parent_row;
            OPEN Dimensions2(parent_row.product_code);
            FETCH Dimensions2 INTO dim2;
            dbms_output.put_line(parent_row.product_code);
            execute immediate ('CREATE TABLE CPT_'||dim.product_code||'(
                '||dim2.product||' varchar2(5)
            )');
            CLOSE Dimensions2;
            FOR I IN 2..parents_count LOOP
                FETCH Parents INTO parent_row;
                OPEN Dimensions2(parent_row.product_code);
                FETCH Dimensions2 INTO dim2;
                execute immediate ('ALTER TABLE CPT_'||dim.product_code||'
                    ADD P'||I||' varchar2(5)
                ');
                CLOSE Dimensions2;
            END LOOP;
            execute immediate ('ALTER TABLE CPT_'||dim.product_code||'
                ADD rownumber number
            ');
            execute immediate ('ALTER TABLE CPT_'||dim.product_code||'
                ADD probability number
            ');
            CLOSE Parents;
            MaxRows := 2 ** parents_count;
            FOR x IN 1..MaxRows LOOP
                ToInsert := '';
                FOR i IN 1..parents_count LOOP 
                    --for first col
                    IF i = 1 THEN
                        IF x <= (MaxRows/2) THEN
                            ToInsert := ToInsert ||'1';
                        ELSE
                            ToInsert := ToInsert ||'0';
                        END IF;
                    --for last col
                    ELSIF i = parents_count THEN
                        IF MOD(x,2) = 1 THEN
                            ToInsert := ToInsert ||',1';
                        ELSE
                            ToInsert := ToInsert ||',0';
                        END IF;
                    --for middle
                    ELSE
                         ToInsert := ToInsert ||','||i||x;
                    END IF;
                END LOOP;
                dbms_output.put_line('ToInsert = '||ToInsert);
                ToInsert := ToInsert ||','||x;
                execute immediate ('INSERT INTO CPT_'||dim.product_code||' 
                    VALUES ('||ToInsert||',null)
                ');
            END LOOP;
        END IF;
        ToInsert := '';
        FOR x IN 2..(parents_count-1) LOOP
            dbms_output.put_line('current col = '||x);
            kk := 0;
            IF (kk != parents_count) OR (kk != 1) THEN
                countermax := 2 ** parents_count / (2**x);
                FOR i IN 1..(2**(x-1)) LOOP
                    WHILE (counter1 != countermax) 
                    LOOP
                        counter1 := counter1 + 1;
                        kk := kk+1;
                        kkk := x||kk;
                        dbms_output.put_line('kkk = '||kkk);
                        dbms_output.put_line('kk = '||kk);
                        execute immediate ('UPDATE CPT_'||dim.product_code||' 
                            SET P'||x||'='||1||'
                            WHERE P'||x||'='||kkk||'
                        ');
                    END LOOP;
                    WHILE (counter0 != countermax) 
                    LOOP
                        counter0 := counter0 + 1;
                        kk := kk+1;
                        kkk := x||kk;
                        dbms_output.put_line('kk = '||kk);
                        dbms_output.put_line('kkk = '||kkk);
                        execute immediate ('UPDATE CPT_'||dim.product_code||' 
                            SET P'||x||'='||0||'
                            WHERE P'||x||'='||kkk||'
                        ');
                    END LOOP;
                    counter0 := 0;
                    counter1 := 0;
                END LOOP;
            END IF;
        END LOOP;
        dbms_output.put_line('ToInsert = '||ToInsert);
        CLOSE Probabilities;
        counter := 1;
        ParentCode := dim.parent_id;
        OPEN Parents(ParentCode);
        FETCH Parents INTO parent_row;
        FOR I IN 2..parents_count LOOP
            FETCH Parents INTO parent_row;
            OPEN Dimensions2(parent_row.product_code);
            FETCH Dimensions2 INTO dim2;
            dbms_output.put_line('dim2.product = '||dim2.product);
            execute immediate ('ALTER TABLE CPT_'||dim.product_code||'
                RENAME COLUMN P'||I||' TO '||dim2.product
            );
            CLOSE Dimensions2;
        END LOOP;
        Close Parents;
        EXECUTE IMMEDIATE ('UPDATE DIMENSION_TABLE
            SET Parent_Count ='||parents_count||
            'WHERE product_code ='||dim.product_code
        );    
    END LOOP;
    CLOSE Dimensions;
    
    counter := 0;
    counter2 := 0;
    
    EXECUTE IMMEDIATE('DELETE FROM pivot_check');
    OPEN Dimensions1;
    LOOP
        FETCH Dimensions1 INTO dim;
        EXIT WHEN Dimensions1%NOTFOUND;
        ParentCode := dim.Parent_ID;
        IF dim.parent_count = 0 THEN
            maxrow := 2;
        ELSE
            maxrow := 2 ** dim.parent_count;
        END IF;
        --parent extraction
        IF dim.parent_count != 0 THEN
            FOR x IN 1..maxrow LOOP
                counter := 0;
                OPEN Parents(ParentCode);
                parentsList := '';
                LOOP
                    FETCH Parents INTO par;
                    EXIT WHEN Parents%NOTFOUND;
                    OPEN Dimensions2(par.product_code);
                    FETCH Dimensions2 INTO dim2;
                    parentsL := dim2.product || ', ';
                    OPEN CountProd(dim2.product_code);
                    FETCH CountProd INTO cProd;
                    numtransact := cProd;
                    CLOSE CountProd;
                    EXECUTE IMMEDIATE ('INSERT INTO check_table
                        SELECT '||dim2.product||'
                        FROM CPT_'||dim.product_code||'
                        WHERE rownumber ='||x
                    );
                    SELECT * INTO chck 
                        FROM check_table
                        WHERE ROWNUM = 1;
                    dbms_output.put_line('TESTING - Product = '||dim.product);
                    dbms_output.put_line('        - Parent = '||dim2.product);
                    dbms_output.put_line('        - From: CPT_'||dim.product_code);
                    dbms_output.put_line('        - Rownumber '||x);
                    dbms_output.put_line('        - Result is '||chck);
                    dbms_output.put_line('        - numtransact = '||numtransact);
                    EXECUTE IMMEDIATE ('DELETE check_table');
                    
                    IF chck = 1 THEN
                        parentsList := parentsList || parentsL;
                        counter := counter + 1;
                        OPEN Probabilities(dim2.product_code);
                        FETCH Probabilities INTO prob;
                        pro := pro * prob.probability;
                        CLOSE Probabilities;
                        OPEN Pivots(par.product_code);
                        kk := 1;
                        --pivot extraction
                        LOOP
                            FETCH Pivots INTO piv;
                            EXIT WHEN Pivots%NOTFOUND;
                            PivotsList(kk) := piv;
                            dbms_output.put_line('TESTING - Product Code: '||dim.product||' Parents: '||PivotsList(kk).product);
                            kk := kk + 1;
                            EXECUTE IMMEDIATE ('INSERT INTO check_pivot
                                SELECT *
                                FROM pivot_table
                                WHERE product_code = '||dim2.product_code
                            );
                        END LOOP;
                        CLOSE Pivots;
                    ELSE
                        OPEN Pivots(par.product_code);
                        kk := 1;
                        --pivot extraction
                        LOOP
                            FETCH Pivots INTO piv;
                            EXIT WHEN Pivots%NOTFOUND;
                            PivotsList(kk) := piv;
                            dbms_output.put_line('TESTING - Product Code: '||dim.product||' Parents: '||PivotsList(kk).product);
                            kk := kk + 1;
                            EXECUTE IMMEDIATE ('INSERT INTO check_pivot2
                                SELECT *
                                FROM pivot_table
                                WHERE product_code = '||dim2.product_code
                            );
                        END LOOP;
                        CLOSE Pivots;
                    END IF;
                    CLOSE Dimensions2;
                END LOOP;
                SELECT * INTO piv FROM Pivot_Table
                    WHERE product_code = dim.product_code;
                PivotsList(kk+1) := piv;
                dbms_output.put_line('TESTING - Product Code: '||dim.product||' Product: '||PivotsList(kk+1).product);
                EXECUTE IMMEDIATE ('INSERT INTO check_pivot
                    SELECT *
                    FROM pivot_table
                    WHERE product_code = '||dim.product_code
                );
                parentsL := dim.product || ', ';
                parentsList := parentsList || parentsL;
                CLOSE Parents;
                EXECUTE IMMEDIATE('DROP TABLE sum_table');
                EXECUTE IMMEDIATE('CREATE TABLE sum_table (summation number)');
                EXECUTE IMMEDIATE('DROP TABLE sum_table2');
                EXECUTE IMMEDIATE('CREATE TABLE sum_table2 (summation number)');
                dbms_output.put_line('        - counter = '||counter);
                dbms_output.put_line('        - Probability = '||pro);
                
                
                IF counter != 0 THEN
                    counter := counter + 1;
                    FOR I IN 1..maxtransact LOOP
                        EXECUTE IMMEDIATE('INSERT INTO sum_table
                            SELECT SUM(N'||I||')
                            FROM check_pivot
                        ');
                        SELECT * INTO CheckSum 
                            FROM sum_table
                            WHERE ROWNUM <= 1;
                        dbms_output.put_line('        - CheckSum = '||CheckSum);
                        IF CheckSum = counter THEN
                            counting := counting + 1;
                        END IF;
                        EXECUTE IMMEDIATE ('DELETE sum_table');
                    END LOOP;
                    dbms_output.put_line('        - counting = '||counting);
                    OPEN Probabilities(dim.product_code);
                    FETCH Probabilities INTO prob;
                    support := counting/maxtransact;
                    confidence := support / prob.probability;
                    CLOSE Probabilities;
                    lift := support / pro;
                ELSE 
                    counter := -1;
                    FOR I IN 1..maxtransact LOOP
                        EXECUTE IMMEDIATE('INSERT INTO sum_table
                            SELECT SUM(N'||I||')
                            FROM check_pivot2
                        ');
                        SELECT * INTO CheckSum 
                            FROM sum_table
                            WHERE ROWNUM <= 1;
                        EXECUTE IMMEDIATE('INSERT INTO sum_table2
                            SELECT SUM(N'||I||')
                            FROM (SELECT *
                            FROM pivot_table
                            WHERE product_code = '||dim.product_code||')
                        ');
                        SELECT * INTO counter2 
                            FROM sum_table2
                            WHERE ROWNUM <= 1;
                        dbms_output.put_line('        - CheckSum = '||CheckSum);
                        dbms_output.put_line('        - counter2 = '||CheckSum);
                        IF CheckSum = 0 AND counter2 = 1 THEN
                            counting := counting + 1;
                        END IF;
                        EXECUTE IMMEDIATE ('DELETE sum_table');
                        EXECUTE IMMEDIATE ('DELETE sum_table2');
                    END LOOP;
                    dbms_output.put_line('        - counting = '||counting);
                    OPEN Probabilities(dim.product_code);
                    FETCH Probabilities INTO prob; 
                    support := counting/maxtransact;
                    confidence := support / prob.probability;
                    CLOSE Probabilities;
                    lift := support / pro;
                END IF;               
                dbms_output.put_line('        - probability(B|A) = '||confidence);
                EXECUTE IMMEDIATE('DELETE check_pivot');
                EXECUTE IMMEDIATE('DELETE check_pivot2');
                EXECUTE IMMEDIATE ('UPDATE CPT_'||dim.product_code||
                    ' SET probability = '||confidence||
                    ' WHERE rownumber = '||x
                );
                dbms_output.put_line('              parentsList = '||parentsList);
                IF confidence != 0 THEN
                    EXECUTE IMMEDIATE ('INSERT INTO cpt_p VALUES('''||parentsList||''', '||confidence||', '||support||', '||lift||')');
                END IF;
                counting := 0;
                pro := 1;
            END LOOP;
        END IF;
    END LOOP;
    CLOSE Dimensions1;
END CREATE_CPT;

/
