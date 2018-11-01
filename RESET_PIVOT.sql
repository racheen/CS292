--------------------------------------------------------
--  File created - Friday-January-26-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure RESET_PIVOT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "SYSTEM"."RESET_PIVOT" AS 
    sqlqry clob;
    cols clob;
    max_product number;
    max_transact number;
    min_transact number;
    ccol clob;

BEGIN
    execute immediate ('DROP TABLE PIVOT_TABLE');
    execute immediate ('CREATE TABLE PIVOT_TABLE (
    product_code varchar2(10),
    product varchar2(10)
    )');
    execute immediate ('DROP TABLE CHECK_PIVOT');
    execute immediate ('CREATE TABLE CHECK_PIVOT (
    product_code varchar2(10),
    product varchar2(10)
    
    )');
    execute immediate ('DROP TABLE CHECK_PIVOT1');
    execute immediate ('CREATE TABLE CHECK_PIVOT1 (
    product_code varchar2(10),
    product varchar2(10)
    )');
    execute immediate ('DROP TABLE CHECK_PIVOT2');

    execute immediate ('CREATE TABLE CHECK_PIVOT2 (
    product_code varchar2(10),
    product varchar2(10)
    )');
    execute immediate ('DROP TABLE TRANSACTION_NAMES');
    execute immediate ('CREATE TABLE TRANSACTION_NAMES(
    t_name varchar2(10)
    )');
    
    select count(distinct invoice_no) into max_transact from SAMPLE_RAW;
--    select listagg('''' || invoice_no || ''' as "' || invoice_no || '"', ',') within group (order by invoice_no)
--    into cols
--    from (select distinct invoice_no from SAMPLE_RAW);
    cols := 1 || '';
    ccol := 'N'||1;
    execute immediate ('ALTER TABLE PIVOT_TABLE
    ADD ' ||ccol|| ' varchar2(10)');
    execute immediate ('INSERT INTO transaction_names VALUES ('''||ccol||''')');
    execute immediate ('ALTER TABLE check_pivot
    ADD ' ||ccol|| ' varchar2(10)');
    execute immediate ('ALTER TABLE check_pivot1
    ADD ' ||ccol|| ' varchar2(10)');
    execute immediate ('ALTER TABLE check_pivot2
    ADD ' ||ccol|| ' varchar2(10)');
    FOR I IN 2..(max_transact-1) LOOP
        cols := cols ||', '|| I;
        ccol := 'N'||I;
        execute immediate ('ALTER TABLE PIVOT_TABLE
        ADD ' ||ccol|| ' varchar2(10)');
        execute immediate ('INSERT INTO transaction_names VALUES ('''||ccol||''')');
        execute immediate ('ALTER TABLE check_pivot
        ADD ' ||ccol|| ' varchar2(10)');
        execute immediate ('ALTER TABLE check_pivot1
    ADD ' ||ccol|| ' varchar2(10)');
        execute immediate ('ALTER TABLE check_pivot2
        ADD ' ||ccol|| ' varchar2(10)');
    END LOOP;
    
    cols := cols ||', '|| max_transact;
    ccol := 'N'||max_transact;
    execute immediate ('ALTER TABLE PIVOT_TABLE
    ADD ' ||ccol|| ' varchar2(10)');
    execute immediate ('INSERT INTO transaction_names VALUES ('''||ccol||''')');
    execute immediate ('ALTER TABLE check_pivot
    ADD ' ||ccol|| ' varchar2(10)');
    execute immediate ('ALTER TABLE check_pivot1
    ADD ' ||ccol|| ' varchar2(10)');
    execute immediate ('ALTER TABLE check_pivot2
    ADD ' ||ccol|| ' varchar2(10)');
    sqlqry :=
    '
    INSERT INTO PIVOT_TABLE
    SELECT * FROM (
           SELECT  invoice_no, product_code, product
           FROM SAMPLE_RAW
        )
    PIVOT (
            count(invoice_no)
            for invoice_no in ('|| cols ||')
        )    ';
    dbms_output.put_line('For cols: '||cols);
    execute immediate sqlqry;
    
    FOR I IN 1..(max_transact) LOOP
        execute immediate ('UPDATE PIVOT_TABLE
            SET N'||I||'=1 
            WHERE N'||I||'>=1
        ');
    END LOOP;
END RESET_PIVOT;

/
