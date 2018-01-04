create or replace procedure GENRATE_BTR_AP_INVOICE(
                                                   
                                                   P_EMP_CODE       in NUMBER,
                                                   P_USER_ID        in NUMBER,
                                                   P_ORG_ID         in NUMBER,
                                                   P_BTR_ID         in NUMBER,
                                                   P_TRAVELING_MODE VARCHAR2,
                                                   P_string         out varchar2)

 is

  P_VENDOR_ID         NUMBER;
  P_VENDOR_SITE_ID    NUMBER;
  P_INVOICE_ID        NUMBER;
  P_INVOICE_LINE_NO   NUMBER NOT NULL DEFAULT 0;
  P_PERSON_ID         NUMBER;
  L_RESPONSIBILITY_ID NUMBER;
  L_APPLICATION_ID    NUMBER;
  REQ_ID              NUMBER;
  CCID_CODE           VARCHAR2(200);
  P_INVOICE_NUMBER    VARCHAR2(200);

  -------------------------------------------FUNCTION-----------------------------
  --*****---------------------------------------------------------------------*****--
  --*****--------------------HEADER LEVEL DATA--------------------------------*****--
  --*****---------------------------------------------------------------------*****--

  CURSOR AP_INVOICE_HEADER IS
    SELECT S.BTR_ID || ' ' || S.EMPLOYEE_CODE || ' ' ||
           TO_CHAR(SYSDATE, 'MON-YY') INVOICE_NUM,
           S.BTR_ID || ' ' || S.EMPLOYEE_CODE || ' ' ||
           TO_CHAR(SYSDATE, 'MON-YY') SUPPLIER_TAX_INVOICE_NUMBER,
           'STANDARD' INVOICE_TYPE_LOOKUP_CODE,
           S.APPLICATION_DATE INVOICE_DATE,
           S.APPLICATION_DATE TAX_INVOICE_RECORDING_DATE,
           '' VENDOR_ID,
           '' VENDOR_SITE_ID,
           S.TOTAL_AMOUNT_SUM * S.CURRENCY_RATE INVOICE_AMOUNT,
           'PKR' INVOICE_CURRENCY_CODE,
           10000 TERMS_ID,
           '' GROUP_ID,
           SYSDATE CREATION_DATE,
           P_USER_ID CREATED_BY,
           'BTR_INV' SOURCE,
           'EFT' PAYMENT_METHOD_CODE,
           SYSDATE GL_DATE,
           'BTR NO ' || S.BTR_NO || ' OF ' || S.EMPLOYEE_CODE ||
           ' PLAN DATE ' || ' ' || S.PLAN_FROM_DATE || ' TO ' ||
           S.PLAN_TO_DATE DESCRIPTION,
           S.OPERATING_UNIT ORG_ID,
           'Acknowledged' ATTRIBUTE1,
           'Service' ATTRIBUTE4,
           NULL DOC_CATEGORY_CODE,
           'Imprest Information' ATTRIBUTE_CATEGORY,
           S.BTR_NO ATTRIBUTE9,
           S.CURRENCY_RATE
    
      FROM TGC_EXP_BTR_HEADER S
     WHERE S.APPROVAL_STATUS = 'Approved'
       AND S.BTR_PAYMENT = 'Unpaid'
       AND S.BTR_ID = P_BTR_ID;

  ----------------------------CURSOR ------------------------------------------

  CURSOR C_AP_INVOICE_LINE IS
  
    SELECT 'ITEM' LINE_TYPE_LOOKUP_CODE,
           S.ELEMENT_NAME,
           S.TOTAL_AMOUNT,
           '' DIST_CODE_COMBINATION_ID
      FROM (SELECT TEBL.ELEMENT_NAME, TEBL.TOTAL_AMOUNT
              FROM TGC_EXP_BTR_LINES TEBL
             WHERE TEBL.BTR_ID = P_BTR_ID
            
            UNION
            
            SELECT 'Ex- Gratia', TEBH.EX_GRATIA_AMOUNT
              FROM TGC_EXP_BTR_HEADER TEBH
             WHERE TEBH.BTR_ID = P_BTR_ID) S;

  ----------------------------PROCEDURE FOR CHECK INVOICE AGAINST BTR------------------------------------------
  PROCEDURE CHECK_BTR_IN_INVOICE(PP_ORG IN NUMBER, PP_BTA_NO NUMBER) IS
  
    PP_INVOICE_NUMBER VARCHAR2(200);
  BEGIN
  
    SELECT S.INVOICE_NUM
      INTO PP_INVOICE_NUMBER
      FROM AP_INVOICES_ALL S
     WHERE UPPER(S.ATTRIBUTE_CATEGORY) = UPPER('IMPREST INFORMATION')
       AND S.ATTRIBUTE9 = PP_BTA_NO
       AND S.ORG_ID = PP_ORG;
  
    IF SQL%FOUND THEN
      DBMS_OUTPUT.PUT_LINE('UNABLE TO PROCESS YOUR TRANSACTION , BTR IS ALREADY EXIST IN INVOICE: ' ||
                           PP_INVOICE_NUMBER);
      RAISE_APPLICATION_ERROR('-20011',
                              'UNABLE TO PROCESS YOUR TRANSACTION , BTR IS ALREADY EXIST IN INVOICE:' ||
                              PP_INVOICE_NUMBER);
    END IF;
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
      NULL;
  END;

  ----------------------------------FUNCTION FOR FIND CCID---------------------

  FUNCTION FIND_CCID(
                     
                     P_PERSON_ID      IN VARCHAR2,
                     P_ORG_ID         IN NUMBER,
                     V_ELEMENT_NAME   IN VARCHAR2,
                     V_MODE_OF_TRAVEL VARCHAR2) RETURN VARCHAR2 IS
    V_CODE VARCHAR2(200);
  BEGIN
  
    SELECT GCC.CODE_COMBINATION_ID
      INTO V_CODE
      FROM GL_CODE_COMBINATIONS_KFV GCC
     WHERE GCC.CONCATENATED_SEGMENTS =
           (SELECT TCOW.COMPANY || '.' || TCOW.UNIT || '.' ||
                   TGC_COST_CENTRE(P_PERSON_ID) || '.' ||
                   TIE.NATURAL_ACCOUNT || '.' || TCOW.INTER_UNIT || '.' ||
                   TCOW.FUTURE1 || '.' || TCOW.FUTURE2 ACCNT
              FROM TGC_CCID_OU_WISE TCOW, TGC_IEXPENSES_ELEMENTS TIE
            
             WHERE 1 = 1
                  
               AND TCOW.ORG_ID = P_ORG_ID
               AND DECODE(TIE.SUB_CAT_ID, 7, 'Domestic', 8, 'International') =
                   V_MODE_OF_TRAVEL
               AND TIE.ELEMENT_NAME = V_ELEMENT_NAME);
    RETURN V_CODE;
  END;

BEGIN

  --BLOCK FOR FIND BTR EMPLOYEE VENDOR_SITE_CODE
  --
  --EXCEPTION
  -- EMPLOYEE VENDOR SITE IS NOT MARKED AS "HOME"
  -- EMPLOYEE VENDOR IS NOT EXIST
  -- EMPLOYEE VENDOR IS MORE THAN ONE ROW

  <<VENDOR_SITE_ID_BLOCK>>
  BEGIN
    SELECT ASS.VENDOR_ID VEN_ID, APSL.VENDOR_SITE_ID, PAAF.PERSON_ID
    
      INTO P_VENDOR_ID, P_VENDOR_SITE_ID, P_PERSON_ID
    
      FROM PER_PEOPLE_X                 PAPF,
           AP_SUPPLIERS                 ASS,
           PER_ORG_STRUCTURE_ELEMENTS_V POSE,
           PER_ORG_STRUCTURE_ELEMENTS_V POSE1,
           HR_ORGANIZATION_UNITS_V      HOUA,
           PER_ALL_ASSIGNMENTS_F        PAAF,
           AP_SUPPLIER_SITES_ALL        APSL
    
     WHERE 1 = 1
       AND PAPF.PERSON_ID = ASS.ATTRIBUTE10
       AND POSE.ORGANIZATION_ID_CHILD = PAAF.ORGANIZATION_ID
       AND APSL.VENDOR_ID = ASS.VENDOR_ID
       AND APSL.ORG_ID = FND_PROFILE.VALUE('ORG_ID')
       AND APSL.VENDOR_SITE_CODE = 'HOME'
       AND ASS.END_DATE_ACTIVE IS NULL
       AND APSL.INACTIVE_DATE IS NULL
       AND POSE.ORGANIZATION_ID_PARENT = POSE1.ORGANIZATION_ID_CHILD
       AND PAPF.PERSON_ID = PAAF.PERSON_ID
       AND PAPF.BUSINESS_GROUP_ID = PAAF.BUSINESS_GROUP_ID
       AND PAPF.BUSINESS_GROUP_ID = PAAF.BUSINESS_GROUP_ID
       AND TRUNC(SYSDATE) BETWEEN PAAF.EFFECTIVE_START_DATE AND
           PAAF.EFFECTIVE_END_DATE
       AND TRUNC(SYSDATE) BETWEEN PAPF.EFFECTIVE_START_DATE AND
           PAPF.EFFECTIVE_END_DATE
       AND PAAF.PRIMARY_FLAG = 'Y'
       AND PAAF.ORGANIZATION_ID = HOUA.ORGANIZATION_ID
       AND POSE1.ORGANIZATION_ID_PARENT = P_ORG_ID
       AND PAAF.ASSIGNMENT_NUMBER = TO_CHAR(P_EMP_CODE);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR('-20011',
                              'UNABLE TO PROCESS YOUR TRANSACTION ,  EMPLOYEE ' ||
                              P_EMP_CODE ||
                              ' VENDOR SITE IS MARKED AS HOME');
  END;

  FOR X IN AP_INVOICE_HEADER LOOP
  
    --- EXECUTE PROCEDURE FOR
    --
    CHECK_BTR_IN_INVOICE(X.ORG_ID, X.ATTRIBUTE9);
    --
  
    <<INVOICE_BLOCK>>
    BEGIN
      SELECT AP_INVOICES_INTERFACE_S.NEXTVAL INTO P_INVOICE_ID FROM DUAL;
    END;
  
    INSERT INTO AP_INVOICES_INTERFACE
      (INVOICE_ID,
       INVOICE_NUM,
       SUPPLIER_TAX_INVOICE_NUMBER,
       INVOICE_TYPE_LOOKUP_CODE,
       INVOICE_DATE,
       TAX_INVOICE_RECORDING_DATE,
       VENDOR_ID,
       VENDOR_SITE_ID,
       INVOICE_AMOUNT,
       INVOICE_CURRENCY_CODE,
       TERMS_ID,
       GROUP_ID,
       CREATION_DATE,
       CREATED_BY,
       SOURCE,
       PAYMENT_METHOD_CODE,
       GL_DATE,
       DESCRIPTION,
       ORG_ID,
       ATTRIBUTE1,
       ATTRIBUTE4,
       DOC_CATEGORY_CODE,
       ATTRIBUTE_CATEGORY,
       ATTRIBUTE9)
    VALUES
      (P_INVOICE_ID,
       X.INVOICE_NUM,
       X.SUPPLIER_TAX_INVOICE_NUMBER,
       X.INVOICE_TYPE_LOOKUP_CODE,
       X.INVOICE_DATE,
       X.TAX_INVOICE_RECORDING_DATE,
       P_VENDOR_ID,
       P_VENDOR_SITE_ID,
       X.INVOICE_AMOUNT,
       X.INVOICE_CURRENCY_CODE,
       X.TERMS_ID,
       X.GROUP_ID,
       X.CREATION_DATE,
       P_USER_ID,
       X.SOURCE,
       X.PAYMENT_METHOD_CODE,
       X.GL_DATE,
       X.DESCRIPTION,
       X.ORG_ID,
       X.ATTRIBUTE1,
       X.ATTRIBUTE4,
       X.DOC_CATEGORY_CODE,
       X.ATTRIBUTE_CATEGORY,
       X.ATTRIBUTE9);
    P_INVOICE_NUMBER := X.INVOICE_NUM;
    COMMIT;
  
    FOR APL IN C_AP_INVOICE_LINE LOOP
    
      P_INVOICE_LINE_NO := P_INVOICE_LINE_NO + 1;
    
      CCID_CODE := FIND_CCID(P_PERSON_ID,
                             X.ORG_ID,
                             APL.ELEMENT_NAME,
                             P_TRAVELING_MODE);
    
      INSERT INTO AP_INVOICE_LINES_INTERFACE
        (INVOICE_ID,
         INVOICE_LINE_ID,
         LINE_NUMBER,
         LINE_TYPE_LOOKUP_CODE,
         ACCOUNTING_DATE,
         DESCRIPTION,
         TAX_CLASSIFICATION_CODE,
         DIST_CODE_COMBINATION_ID,
         ORG_ID,
         AMOUNT,
         CREATION_DATE,
         CREATED_BY)
      VALUES
        (P_INVOICE_ID,
         AP_INVOICE_LINES_INTERFACE_S.NEXTVAL,
         P_INVOICE_LINE_NO,
         'ITEM',
         SYSDATE,
         X.DESCRIPTION,
         NULL,
         CCID_CODE, ------------
         X.ORG_ID,
         ROUND(APL.TOTAL_AMOUNT * X.CURRENCY_RATE, 2),
         SYSDATE,
         P_USER_ID
         
         );
      DBMS_OUTPUT.PUT_LINE('INVOICE NO ' || P_INVOICE_ID);
    END LOOP;
  
  END LOOP;

  -----------------------------------------------------------------------------
  ---------GETTING RESPONSIBILITY_ID & APPLICATION_ID OF PAYABLES--------------
  -----------------------------------------------------------------------------
  SELECT DISTINCT FR.RESPONSIBILITY_ID, FRX.APPLICATION_ID
    INTO L_RESPONSIBILITY_ID, L_APPLICATION_ID
    FROM APPS.FND_RESPONSIBILITY FRX, APPS.FND_RESPONSIBILITY_TL FR
   WHERE FR.RESPONSIBILITY_ID = FRX.RESPONSIBILITY_ID
     AND FR.RESPONSIBILITY_ID = 20639;

  APPS.FND_GLOBAL.APPS_INITIALIZE(P_USER_ID,
                                  L_RESPONSIBILITY_ID,
                                  L_APPLICATION_ID);

  -----------------------------------------------------------------------------
  ----------------------SUBMITTING CONCURRENT REQUEST--------------------------
  -----------------------------------------------------------------------------

  DBMS_OUTPUT.PUT_LINE('REQUEST SUBMISSION');

  REQ_ID := FND_REQUEST.SUBMIT_REQUEST('SQLAP',
                                       'APXIIMPT',
                                       '',
                                       NULL,
                                       FALSE,
                                       P_ORG_ID, -- OPERATING UNIT
                                       'BTR_INV', --'MANUAL INVOICE ENTRY',        -- SOURCE
                                       NULL, -- GROUP
                                       'IEXPENSE INVOICES', -- BATCH NAME
                                       '', -- HOLD NAME
                                       '', -- HOLD REASON
                                       NULL, -- GL_DATE
                                       'N', -- PURGE_FLAG
                                       'Y', -- TRACE SWITCH
                                       'Y', -- DEBUG SWITCH
                                       'N', -- SUMMERIZED FLAGE
                                       1000 -- COMMIT BATCH SIZE
                                       );
  COMMIT;

  --

  P_string := 'REQUEST SUBMISSION' || 'PROCEDURE COMPLIED SUCCESSFULLY ' ||
              ' RQ ID' || REQ_ID || ' INVOICE NO: ' || P_INVOICE_NUMBER ||
              ' INVOICE ID ' || P_INVOICE_ID;

END;
/
