DECLARE

  ---------------------PROCEDURE------------------
    PROCEDURE PROC_GET_QUERY (
                              V_TABLE_NAME IN VARCHAR2,
                              REQ_COLUMN  IN NUMBER,
                              v_owner varchar2 
                              ) 
          IS 
          
        CURSOR CR_USER_TAB 
               IS 
               SELECT S.COLUMN_NAME
               FROM all_tab_columns S
               WHERE S.TABLE_NAME=UPPER(V_TABLE_NAME)
               and s.OWNER=nvl(v_owner,user)
               AND (ROWNUM <=REQ_COLUMN or REQ_COLUMN is null)
               ORDER BY S.COLUMN_ID ASC;
                
        V_QUERY VARCHAR2(32767):='ROWNUM';

    BEGIN 
      
    DBMS_OUTPUT.enable(90000);

    FOR XN IN CR_USER_TAB  LOOP 
      
    V_QUERY:=V_QUERY||' , '||XN.COLUMN_NAME;

    END LOOP;
    DBMS_OUTPUT.PUT_LINE(' SELECT ' || V_QUERY ||' FROM '|| V_TABLE_NAME ||' WHERE 1=1 ' );

    END;
   --------------------------------------
   
   
BEGIN 
/*

PROC_GET_QUERY( 
    V_TABLE_NAME => YOUR TABLE NAME ,
    REQ_COLUMN => NUMBER OF COLUMNS THAT YOU HAVE REQUIRED TO GET FROM TABLE , NULL FOR GET ALL COLUMNS 
    v_owner => BY DEFAULT YOUR USER , YOU CAN GET QUERY FOR OTHER SCHEMA
*/
  
  

  PROC_GET_QUERY('DUAL',null,null);


END;
