--------------------------------------------------------
--  File created - Friday-January-26-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure DROPCPTTABLE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "SYSTEM"."DROPCPTTABLE" AS 
BEGIN
  FOR c IN ( SELECT table_name FROM user_tables WHERE table_name LIKE 'CPT_%' )
  LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || c.table_name;
  END LOOP;
END DROPCPTTABLE;

/
