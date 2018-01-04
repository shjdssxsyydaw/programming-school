select
EMPLOYEE_NUMBER,
ASSIGNMENT_NUMBER,
TITLE,
FULL_NAME,
LAST_NAME,
GENDER,
MARITAL_STATUS,
PERSON_TYPE,
employment_category,
--Higest_Qualification,
--Educational_Institute,
Last_Tranfer_Date,
OLD_POSITION,
poa_number,
to_char(fnd_date.CANONICAL_TO_DATE (POA_issuance_date),'DD-Mon-YYYY') POA_issuance_date, 
to_char(fnd_date.CANONICAL_TO_DATE (POA_Cancelation_Date),'DD-Mon-YYYY') POA_Cancelation_Date,
cnic,
CNIC_Issuance_dt,
CNIC_Expiry_dt,
ntn_number,
passport,
cell_phone,
DATE_OF_BIRTH,
Joining_Date,
Confirmation_Date, 
CONFRM_DUE_DATE,
Retirement_Date,
Contract_Expiry,
org, 
parent_org,
    case when org like '%GROUP'
    then org 
    else
    group_name
    end 
    group_name ,
BRANCH_SUBUNIT_NAME,
AREA_UNIT_NAME,
REGION_DEPARTMENT_NAME,
DIVISION_BUSINESS_NAME,
COMPANY,
BUSINESS_SEGMENT,
COST_CENTER,
INTER_BRANCH,
EXCEPTION1,
grade,
job,
position,
location,
POSTING_CATEGORY,
supervisor,
supervisor_emp#,
PROBATION_PERIOD,
PROBATION_UNIT,
NOTICE_PERIOD,
NOTICE_PERIOD_UOM,
SALARY_BRANCH,
Acount_Number,
LAST_WORKING_DAY,
NOTIFIED_TERMINATION_DATE,
LEAVING_REASON,
Resignation_Reason,
Religion,
blood_group,
EMAIL_ADDRESS,
NATIONALITY,
basic,
house,
utility,
base_salary,
IBP_Ear_Ach_All,
Conveyance_Allowance,
Functional_Fuel,
Furniture_Allowance,
Special_Allowance,
Cell_Phone_Allw,
Title_Allowance,
Car_Allowance,
FT_Allowance,
Driver_Allowance,
Tel_Residence,
Rental_Allowance,
Bank_Car_Fuel,
rating1,
rating2,
rating3,
contract_date,
    CASE WHEN DA_INITIATED ='Y'
     THEN 'Y'
     ELSE 'N'
     END DA_INITIATED,
DECISION

from  
(


select 
PAPF.EMPLOYEE_NUMBER,
paaf.EFFECTIVE_START_DATE ,
paaf.EFFECTIVE_end_DATE ,
paaf.ASSIGNMENT_NUMBER,
papf.TITLE,
papf.FULL_NAME,
papf.LAST_NAME,
papf.ATTRIBUTE2 Religion,
papf.ATTRIBUTE3 blood_group,
papf.EMAIL_ADDRESS,
papf.NATIONALITY,
paaf.DATE_PROBATION_END CONFRM_DUE_DATE,
paaf.PROBATION_PERIOD,
paaf.PROBATION_UNIT,
paaf.NOTICE_PERIOD,
paaf.NOTICE_PERIOD_UOM,
CASE WHEN PAAF.PEOPLE_GROUP_ID = 1062
THEN 'No'
WHEN PAAF.PEOPLE_GROUP_ID = 2062
THEN 'Yes'
ELSE ''
END EXCEPTION1,
case when papf.sex = 'M'
THEN 'Male'
when papf.sex = 'F'
THEN 'Female'
else ''
end GENDER,

case when papf.MARITAL_STATUS = 'M'
THEN 'Married'
when papf.MARITAL_STATUS = 'S'
THEN 'Single'
else ''
end MARITAL_STATUS,
 decode  (paaf.assignment_type,
                   'E', hr_general.decode_lookup ('EMP_CAT',
                                                  paaf.employment_category
                                                 ),
                   'C', hr_general.decode_lookup ('CWK_ASG_CATEGORY',
                                                  paaf.employment_category
                                                 )
                  ) employment_category,
papf.NATIONAL_IDENTIFIER cnic,
to_char(fnd_date.CANONICAL_TO_DATE (papf.ATTRIBUTE8),'DD-Mon-YYYY') CNIC_Issuance_dt,
to_char(fnd_date.CANONICAL_TO_DATE (papf.ATTRIBUTE11),'DD-Mon-YYYY') CNIC_Expiry_dt,
papf.ATTRIBUTE20 ntn_number,
papf.ATTRIBUTE28 passport,
to_char(papf.DATE_OF_BIRTH,'DD-Mon-YYYY')DATE_OF_BIRTH,
TO_CHAR(PAPF.START_DATE,'DD-Mon-YYYY') Joining_Date,

(
select pqv.TITLE
     from PER_QUALIFICATION_TYPES pqtv,
    PER_QUALIFICATIONS_V pqv,
        per_all_people_f papf2
     where 
     pqtv.QUALIFICATION_TYPE_ID(+) = pqv.QUALIFICATION_TYPE_ID
     and papf2.PERSON_ID = pqv.PERSON_ID(+)
    and papf2.PERSON_ID = papf.PERSON_ID
    and sysdate between papf2.EFFECTIVE_START_DATE and papf2.EFFECTIVE_END_DATE
     and pqtv.RANK = ( select max(pqtv1.RANK)
 
    from PER_QUALIFICATION_TYPES pqtv1,
    PER_QUALIFICATIONS pqv1
    where pqtv1.QUALIFICATION_TYPE_ID = pqv1.QUALIFICATION_TYPE_ID
    and papf2.PERSON_ID = pqv1.PERSON_ID

     )
    and rownum =1
    )Higest_Qualification,
  
  
  (  select distinct ESTABLISHMENT
     from PER_QUALIFICATION_TYPES pqtv,
    PER_QUALIFICATIONS_V pqv,
        per_all_people_f papf2
     where 
     pqtv.QUALIFICATION_TYPE_ID(+) = pqv.QUALIFICATION_TYPE_ID
     and papf2.PERSON_ID = pqv.PERSON_ID(+)
    and papf2.PERSON_ID = papf.PERSON_ID
    and sysdate between papf2.EFFECTIVE_START_DATE and papf2.EFFECTIVE_END_DATE
     and pqtv.RANK = ( select max(pqtv1.RANK)
 
    from PER_QUALIFICATION_TYPES pqtv1,
    PER_QUALIFICATIONS pqv1
    where pqtv1.QUALIFICATION_TYPE_ID = pqv1.QUALIFICATION_TYPE_ID
    and papf2.PERSON_ID = pqv1.PERSON_ID

     )
    and rownum =1
)Educational_Institute,


  nvl(to_char((select distinct min(paafa.EFFECTIVE_START_DATE)   
                      from  per_all_people_f    papfa
                           ,per_all_assignments_f paafa
                      where papfa.PERSON_ID = paafa.PERSON_ID
                            and papfa.PERSON_ID = papf.PERSON_ID
                            and paafa.EMPLOYMENT_CATEGORY = 'BAFL_CONF'),'DD-MON-YYYY') 
                        , 'NA') Confirmation_Date,
 (SELECT     org.NAME
                      FROM hr_organization_units_v org,
                          bafl_org_structure_elements_v ose
                     WHERE 1 = 1
                       AND org.organization_id = ose.organization_id_parent
                       AND org.organization_type = 'Group'
                START WITH ose.organization_id_child = haou.organization_id
                CONNECT BY PRIOR ose.organization_id_parent = ose.organization_id_child
                
                ) group_name,
                
                    (
    SELECT haou.NAME
    FROM per_org_structure_elements pose, HR_ALL_ORGANIZATION_UNITS HAOU
    WHERE POSE.ORGANIZATION_ID_CHILD = haou.ORGANIZATION_ID
    AND HAOU.TYPE IN ('BRANCH', 'SUB_UNIT')
    start with pose.ORGANIZATION_ID_CHILD = paaf.ORGANIZATION_ID
    CONNECT BY PRIOR POSE.ORGANIZATION_ID_PARENT = POSE.ORGANIZATION_ID_CHILD
    AND ROWNUM = 1
    )    BRANCH_SUBUNIT_NAME,


    (

    SELECT haou.NAME
    FROM per_org_structure_elements pose, HR_ALL_ORGANIZATION_UNITS HAOU
    WHERE POSE.ORGANIZATION_ID_CHILD = haou.ORGANIZATION_ID
    AND HAOU.TYPE IN ('AREA', 'UNIT')
    start with pose.ORGANIZATION_ID_CHILD = paaf.ORGANIZATION_ID
    CONNECT BY PRIOR POSE.ORGANIZATION_ID_PARENT = POSE.ORGANIZATION_ID_CHILD
    AND ROWNUM = 1
    )    AREA_UNIT_NAME,

    (

    SELECT haou.NAME
    FROM per_org_structure_elements pose, HR_ALL_ORGANIZATION_UNITS HAOU
    WHERE POSE.ORGANIZATION_ID_CHILD = haou.ORGANIZATION_ID
    AND HAOU.TYPE IN ('REGION', 'DEPARTMENT')
    start with pose.ORGANIZATION_ID_CHILD = paaf.ORGANIZATION_ID
    CONNECT BY PRIOR POSE.ORGANIZATION_ID_PARENT = POSE.ORGANIZATION_ID_CHILD
    AND ROWNUM = 1
    )    REGION_DEPARTMENT_NAME,


    (

    SELECT haou.NAME
    FROM per_org_structure_elements pose, HR_ALL_ORGANIZATION_UNITS HAOU
    WHERE POSE.ORGANIZATION_ID_CHILD = haou.ORGANIZATION_ID
    AND HAOU.TYPE IN ('DIVISION', 'BUSINESS')
    start with pose.ORGANIZATION_ID_CHILD = paaf.ORGANIZATION_ID
    CONNECT BY PRIOR POSE.ORGANIZATION_ID_PARENT = POSE.ORGANIZATION_ID_CHILD
    )    DIVISION_BUSINESS_NAME,

                
    (
    Select pap.NAME
    from  Per_all_assignments_f    PAAF5,
     per_all_positions pap
    
    
     WHERE 
     PAAF5.POSITION_ID = PAP.POSITION_ID
     AND PAAF5.PERSON_ID = PAAF.PERSON_ID
      AND PAAF5.EFFECTIVE_START_DATE = 
    (

    Select max(PAAF4.EFFECTIVE_START_DATE)
    --PAP1.NAME
            from
             per_all_positions pap1,
    Per_all_assignments_f PAAF4
    WHERE PAAF4.POSITION_ID = PAP1.POSITION_ID
    --AND PAAF4.EFFECTIVE_START_DATE < PAAF.EFFECTIVE_START_DATE 
    --and TO_DATE(SYSDATE)-1 between paaf4.EFFECTIVE_START_DATE and paaf4.EFFECTIVE_END_DATE
    AND PAAF4.ASSIGNMENT_NUMBER= PAAF.ASSIGNMENT_NUMBER
    and PAAF4.EFFECTIVE_START_DATE < PAAF.EFFECTIVE_START_DATE
    AND PAAF4.POSITION_ID <> PAAF.POSITION_ID 

     )
     )OLD_POSITION,
     (  select DISTINCT SEGMENT2 
                  from
                 PER_ANALYSIS_CRITERIA pac,
                 PER_PERSON_ANALYSES ppa,
                 fnd_id_flex_structures fifs
                 where ppa.ANALYSIS_CRITERIA_ID = pac.ANALYSIS_CRITERIA_ID
                     and fifs.ID_FLEX_NUM = ppa.ID_FLEX_NUM
                 and fifs.ID_FLEX_STRUCTURE_CODE = 'Power Of Attorney'
            
                 and ppa.PERSON_ID =papf.PERSON_ID --19381
                and date_from =( select max(ppa1.DATE_FROM)
                 from PER_ANALYSIS_CRITERIA pac1,
                PER_PERSON_ANALYSES ppa1,
                 fnd_id_flex_structures fifs1
                where fifs1.ID_FLEX_STRUCTURE_CODE = 'Power Of Attorney'
                and ppa1.ANALYSIS_CRITERIA_ID = pac1.ANALYSIS_CRITERIA_ID
                     and fifs1.ID_FLEX_NUM = ppa1.ID_FLEX_NUM
                     and ppa1.PERSON_ID =ppa.PERSON_ID--19381
                     )
                     and rownum=1
                     )poa_number , 
                         (  select DISTINCT SEGMENT6 --,SEGMENT9 cancelation_date
                  from
                 PER_ANALYSIS_CRITERIA pac,
                 PER_PERSON_ANALYSES ppa,
                 fnd_id_flex_structures fifs
                 where ppa.ANALYSIS_CRITERIA_ID = pac.ANALYSIS_CRITERIA_ID
                     and fifs.ID_FLEX_NUM = ppa.ID_FLEX_NUM
                 and fifs.ID_FLEX_STRUCTURE_CODE = 'Power Of Attorney'
            
                 and ppa.PERSON_ID =papf.PERSON_ID --19381
                and date_from =( select max(ppa1.DATE_FROM)
                 from PER_ANALYSIS_CRITERIA pac1,
                PER_PERSON_ANALYSES ppa1,
                 fnd_id_flex_structures fifs1
                where fifs1.ID_FLEX_STRUCTURE_CODE = 'Power Of Attorney'
                and ppa1.ANALYSIS_CRITERIA_ID = pac1.ANALYSIS_CRITERIA_ID
                     and fifs1.ID_FLEX_NUM = ppa1.ID_FLEX_NUM
                     and ppa1.PERSON_ID =ppa.PERSON_ID--19381
                     )
                     and rownum=1
                     )POA_issuance_date, 
                         (  select DISTINCT SEGMENT9 
                  from
                 PER_ANALYSIS_CRITERIA pac,
                 PER_PERSON_ANALYSES ppa,
                 fnd_id_flex_structures fifs
                 where ppa.ANALYSIS_CRITERIA_ID = pac.ANALYSIS_CRITERIA_ID
                     and fifs.ID_FLEX_NUM = ppa.ID_FLEX_NUM
                 and fifs.ID_FLEX_STRUCTURE_CODE = 'Power Of Attorney'
            
                 and ppa.PERSON_ID =papf.PERSON_ID --19381
                and date_from =( select max(ppa1.DATE_FROM)
                 from PER_ANALYSIS_CRITERIA pac1,
                PER_PERSON_ANALYSES ppa1,
                 fnd_id_flex_structures fifs1
                where fifs1.ID_FLEX_STRUCTURE_CODE = 'Power Of Attorney'
                and ppa1.ANALYSIS_CRITERIA_ID = pac1.ANALYSIS_CRITERIA_ID
                     and fifs1.ID_FLEX_NUM = ppa1.ID_FLEX_NUM
                     and ppa1.PERSON_ID =ppa.PERSON_ID--19381
                     )
                     and rownum=1
                     )POA_Cancelation_Date , 
                     
 ( select haou1.NAME from hr_all_organization_units haou1
where haou1.ORGANIZATION_ID =(
select pose.ORGANIZATION_ID_PARENT from per_org_structure_elements_v pose
where pose.ORGANIZATION_ID_CHILD = haou.ORGANIZATION_ID )
)parent_org,


(
select OVERRIDE_VALUE from BAFL_ENTITLEMENT_DETAIL_V
where ELEMENT_NAME='Conveyance Allowance'
and person_id = papf.person_id )Conveyance_Allowance,

(
select OVERRIDE_VALUE from BAFL_ENTITLEMENT_DETAIL_V
where ELEMENT_NAME='Furniture Allowance'
and person_id = papf.person_id )Furniture_Allowance,

(
select OVERRIDE_VALUE from BAFL_ENTITLEMENT_DETAIL_V
where ELEMENT_NAME='Special Allowance'
and person_id = papf.person_id )Special_Allowance,

(
select OVERRIDE_VALUE from BAFL_ENTITLEMENT_DETAIL_V
where ELEMENT_NAME='Cell Phone Allowance'
and person_id = papf.person_id )Cell_Phone_Allw,

(
select OVERRIDE_VALUE from BAFL_ENTITLEMENT_DETAIL_V
where ELEMENT_NAME='Title Allowance'
and person_id = papf.person_id )Title_Allowance,
(
select OVERRIDE_VALUE from BAFL_ENTITLEMENT_DETAIL_V
where ELEMENT_NAME='Car Allowance'
and person_id = papf.person_id )Car_Allowance,

(
select OVERRIDE_VALUE from BAFL_ENTITLEMENT_DETAIL_V
where ELEMENT_NAME='Telephone Residence Allowance'
and person_id = papf.person_id )Tel_Residence,
(
select OVERRIDE_VALUE from BAFL_ENTITLEMENT_DETAIL_V
where ELEMENT_NAME='Rental Allowance'
and person_id = papf.person_id )Rental_Allowance,
(
select OVERRIDE_VALUE from BAFL_ENTITLEMENT_DETAIL_V
where ELEMENT_NAME='Bank Car Fuel'
and person_id = papf.person_id )Bank_Car_Fuel,
(
select OVERRIDE_VALUE from BAFL_ENTITLEMENT_DETAIL_V
where ELEMENT_NAME='Driver Allowance'
and person_id = papf.person_id )Driver_Allowance,
(
select OVERRIDE_VALUE from BAFL_ENTITLEMENT_DETAIL_V
where ELEMENT_NAME='FT Allowance'
and person_id = papf.person_id )FT_Allowance,

(
select OVERRIDE_VALUE from BAFL_ENTITLEMENT_DETAIL_V
where ELEMENT_NAME='Functional Fuel'
and person_id = papf.person_id )Functional_Fuel,

(
select OVERRIDE_VALUE from BAFL_ENTITLEMENT_DETAIL_V
where ELEMENT_NAME='IBP Earlier Achiver Allowance'
and person_id = papf.person_id )IBP_Ear_Ach_All,

(select rating_meaning
from per_performance_reviews_v
WHERE person_id = papf.PERSON_ID --14325
AND REVIEW_DATE = (Select MAX(REVIEW_DATE)
from per_performance_reviews_v
WHERE person_id = papf.PERSON_ID --14325
AND TO_CHAR(REVIEW_DATE,'YYYY') = NVL(TO_CHAR(:P_date,'YYYY'),TO_CHAR(sysdate,'YYYY'))
)
)rating1,

(select rating_meaning
from per_performance_reviews_v
WHERE person_id =  papf.PERSON_ID
AND REVIEW_DATE = (Select MAX(REVIEW_DATE)
from per_performance_reviews_v
WHERE person_id = papf.PERSON_ID
AND TO_CHAR(REVIEW_DATE,'YYYY') = NVL(TO_CHAR(add_months(:P_date,-12),'YYYY'),TO_CHAR(add_months(sysdate,-12),'YYYY'))

)
)rating2,

(
select rating_meaning
from per_performance_reviews_v
WHERE person_id = papf.PERSON_ID
AND REVIEW_DATE = (Select MAX(REVIEW_DATE)
from per_performance_reviews_v
WHERE person_id = papf.PERSON_ID
AND TO_CHAR(REVIEW_DATE,'YYYY') = NVL(TO_CHAR(add_months(:P_date,-24),'YYYY'),TO_CHAR(add_months(sysdate,-24),'YYYY'))
 
)
)rating3,
(select  to_char(max(pcf.DESCRIPTION))
          --max(fnd_date.CHARDATE_TO_DATE(pcf.DESCRIPTION))
          from per_contracts_f pcf ,per_all_people_f papf7
          where
          pcf.person_id=papf7.PERSON_ID
          and sysdate between papf7.EFFECTIVE_START_DATE and papf7.EFFECTIVE_END_DATE
           and sysdate between pcf.EFFECTIVE_START_DATE and pcf.EFFECTIVE_END_DATE
          and papf7.PERSON_ID=papf.PERSON_ID
          
          )contract_date,
          hr_general.decode_lookup ('EMPLOYEE_CATG', EMPLOYEE_CATEGORY) POSTING_CATEGORY,
                   
      (      select 
 to_char(MAX(paaf.EFFECTIVE_START_DATE),'DD-MM-YYYY') EFFECTIVE_START_DATE
from  per_all_people_f             papf9
     ,per_all_assignments_f        paaf9
     ,per_grades                   pg1
    ,hr_all_organization_units_tl otl1
    ,per_positions pp1
    ,hr_locations hl1
    ,pay_payrolls pay1
    ,per_jobs pj1
 where papf9.PERSON_ID = paaf9.PERSON_ID
 --and trunc(paaf.LAST_UPDATE_DATE ) between :p_date_from and :p_date_to
 and sysdate between papf9.EFFECTIVE_START_DATE and papf9.EFFECTIVE_END_DATE 

 and pg1.GRADE_ID (+)= paaf9.GRADE_ID
 and otl1.ORGANIZATION_ID (+) = paaf9.ORGANIZATION_ID
 and pp1.POSITION_ID (+) = paaf9.POSITION_ID
 and hl1.LOCATION_ID (+)= paaf9.LOCATION_ID
 and pay1.PAYROLL_Id (+)= paaf9.PAYROLL_ID
 and pj1.JOB_ID(+)  = paaf9.JOB_ID

       and 
            (     
  exists
       (
       select 1
       from per_all_assignments_f paafaa
       where paaf9.EFFECTIVE_START_DATE -1 between paafaa.EFFECTIVE_START_DATE and paafaa.EFFECTIVE_END_DATE
       and paafaa.POSITION_ID <> paaf9.POSITION_ID
       and paafaa.PERSON_ID = paaf9.PERSON_ID
       )
       OR EXISTS
              (
       select 1
       from per_all_assignments_f paafaa
       where paaf9.EFFECTIVE_START_DATE -1 between paafaa.EFFECTIVE_START_DATE and paafaa.EFFECTIVE_END_DATE
       and paafaa.EMPLOYEE_CATEGORY <> paaf9.EMPLOYEE_CATEGORY
       and paafaa.PERSON_ID = paaf9.PERSON_ID
       )
       
            )
           AND PAPF9.PERSON_ID=PAPF.PERSON_ID
)Last_Tranfer_Date,


(
select ppt.USER_PERSON_TYPE
  from per_person_types ppt,
per_person_type_usages_f pptu

where
 ppt.PERSON_TYPE_ID(+)=pptu.PERSON_TYPE_ID
and  papf.PERSON_ID=pptu.PERSON_ID
and pptu.EFFECTIVE_START_DATE= (Select MAX(pptu1.EFFECTIVE_START_DATE)
FROM per_person_type_usages_f pptu1
wHERE pptu1.PERSON_ID = (PAPF.PERSON_ID) )
and (PPTU.EFFECTIVE_START_DATE < :p_date  or  PPTU.EFFECTIVE_END_DATE < :p_date)
AND PPT.SYSTEM_PERSON_TYPE ='EMP'
--AND ROWNUM=1
) PERSON_TYPE ,


(
select  case when ppt.USER_PERSON_TYPE = 'Contractual Employee'
then 'NA'
else
concat(to_char(papf.DATE_OF_BIRTH,'dd-Mon-') ,to_char(papf.DATE_OF_BIRTH,'yyyy')+60)
end
  from per_person_types ppt,
per_person_type_usages_f pptu

where
 ppt.PERSON_TYPE_ID(+)=pptu.PERSON_TYPE_ID
and  papf.PERSON_ID=pptu.PERSON_ID
and pptu.EFFECTIVE_START_DATE= (Select MAX(pptu1.EFFECTIVE_START_DATE)
FROM per_person_type_usages_f pptu1
wHERE pptu1.PERSON_ID = (PAPF.PERSON_ID) )
and (PPTU.EFFECTIVE_START_DATE < :p_date  or  PPTU.EFFECTIVE_END_DATE < :p_date)
AND PPT.SYSTEM_PERSON_TYPE ='EMP'
--AND ROWNUM=1
) Retirement_Date,

(
 select case when ppt.USER_PERSON_TYPE = 'Contractual Employee'
  THEN BAFL_GET_CONTRACT_DATE(Paaf.ASSIGNMENT_ID)
  ELSE NULL
  END
  from per_person_types ppt,
per_person_type_usages_f pptu

where
 ppt.PERSON_TYPE_ID(+)=pptu.PERSON_TYPE_ID
and  papf.PERSON_ID=pptu.PERSON_ID
and pptu.EFFECTIVE_START_DATE= (Select MAX(pptu1.EFFECTIVE_START_DATE)
FROM per_person_type_usages_f pptu1
wHERE pptu1.PERSON_ID = (PAPF.PERSON_ID) )
and (PPTU.EFFECTIVE_START_DATE < :p_date  or  PPTU.EFFECTIVE_END_DATE < :p_date)
AND PPT.SYSTEM_PERSON_TYPE ='EMP'
--AND ROWNUM=1
)  Contract_Expiry,


(
select distinct sup.FULL_NAME
from per_all_people_f sup
where sup.EFFECTIVE_START_DATE= (select max(sup1.EFFECTIVE_START_DATE) from per_all_people_f sup1
where sup1.PERSON_ID = sup.PERSON_ID)
AND sup.person_id = paaf.supervisor_id
AND (sup.EFFECTIVE_START_DATE < :P_DATE OR sup.EFFECTIVE_END_DATE < :P_DATE)
) supervisor,

(
select distinct EMPLOYEE_NUMBER
from per_all_people_f sup
where sup.EFFECTIVE_START_DATE= (select max(sup1.EFFECTIVE_START_DATE) from per_all_people_f sup1
where sup1.PERSON_ID = sup.PERSON_ID)
AND sup.person_id = paaf.supervisor_id
AND (sup.EFFECTIVE_START_DATE < :P_DATE OR sup.EFFECTIVE_END_DATE < :P_DATE)
) supervisor_emp#,

(
Select pea.SEGMENT1  from 
pay_personal_payment_methods_f ppm,
pay_external_accounts pea
WHERE 
 pea.EXTERNAL_ACCOUNT_ID(+) = ppm.EXTERNAL_ACCOUNT_ID
and ppm.ASSIGNMENT_ID(+) = paaf.ASSIGNMENT_ID
AND PPM.EFFECTIVE_START_DATE = (SELECT MAX(PPM1.EFFECTIVE_START_DATE)
FROM pay_personal_payment_methods_f ppm1,
pay_external_accounts pea1
WHERE 
 pea1.EXTERNAL_ACCOUNT_ID(+) = ppm1.EXTERNAL_ACCOUNT_ID
and ppm1.ASSIGNMENT_ID = paaf.ASSIGNMENT_ID
)
AND (PPM.EFFECTIVE_START_DATE < :P_DATE OR PPM.EFFECTIVE_END_DATE < :P_DATE)
)Acount_Number,

(Select ppsc.NOTIFIED_TERMINATION_DATE

FROM per_periods_of_service_v ppsc
WHERE ppsc.PERSON_ID = papf.PERSON_ID
AND PPSC.DATE_START = (Select MAX(PPSC.DATE_START) from
per_periods_of_service_v ppsc
WHERE PPSC.PERSON_ID = PAPF.PERSON_ID
AND (PPSC.DATE_START < :P_DATE )
  )
)NOTIFIED_TERMINATION_DATE,


(Select 
ppsc.ACTUAL_TERMINATION_DATE

FROM per_periods_of_service_v ppsc
WHERE ppsc.PERSON_ID = papf.PERSON_ID
AND PPSC.DATE_START = (Select MAX(PPSC.DATE_START) from
per_periods_of_service_v ppsc
WHERE PPSC.PERSON_ID = PAPF.PERSON_ID
AND (PPSC.DATE_START < :P_DATE )
  )
) LAST_WORKING_DAY,

(Select 
ppsc.D_LEAVING_REASON

FROM per_periods_of_service_v ppsc
WHERE ppsc.PERSON_ID = papf.PERSON_ID
AND PPSC.DATE_START = (Select MAX(PPSC.DATE_START) from
per_periods_of_service_v ppsc
WHERE PPSC.PERSON_ID = PAPF.PERSON_ID
AND (PPSC.DATE_START < :P_DATE )
  )
) LEAVING_REASON,

(Select 
ppsc.ATTRIBUTE2 

FROM per_periods_of_service_v ppsc
WHERE ppsc.PERSON_ID = papf.PERSON_ID
AND PPSC.DATE_START = (Select MAX(PPSC.DATE_START) from
per_periods_of_service_v ppsc
WHERE PPSC.PERSON_ID = PAPF.PERSON_ID
AND (PPSC.DATE_START < :P_DATE )
  )
) Resignation_Reason,

(Select ppp.PROPOSED_SALARY_N
 from per_pay_proposals ppp 
WHERE  paaf.ASSIGNMENT_ID = ppp.assignment_id
AND ppp.CHANGE_DATE =(SELECT MAX(ppp1.CHANGE_DATE)
FROM per_pay_proposals ppp1  
WHERE paaf.ASSIGNMENT_ID = ppp1.assignment_id
 )
 AND (ppp.CHANGE_DATE < :P_DATE  )
)base_salary,

(Select round(nvl(ppp.PROPOSED_SALARY_N,0)/150*100)
 from per_pay_proposals ppp 
WHERE  paaf.ASSIGNMENT_ID = ppp.assignment_id
AND ppp.CHANGE_DATE =(SELECT MAX(ppp1.CHANGE_DATE)
FROM per_pay_proposals ppp1  
WHERE paaf.ASSIGNMENT_ID = ppp1.assignment_id
 )
 AND (ppp.CHANGE_DATE < :P_DATE  )
)basic,

(Select round(nvl(ppp.PROPOSED_SALARY_N,0)/150*40) 
 from per_pay_proposals ppp 
WHERE  paaf.ASSIGNMENT_ID = ppp.assignment_id
AND ppp.CHANGE_DATE =(SELECT MAX(ppp1.CHANGE_DATE)
FROM per_pay_proposals ppp1  
WHERE paaf.ASSIGNMENT_ID = ppp1.assignment_id
 )
 AND (ppp.CHANGE_DATE < :P_DATE  )
)house,

(Select round(nvl(ppp.PROPOSED_SALARY_N,0)/150*10)
 from per_pay_proposals ppp 
WHERE  paaf.ASSIGNMENT_ID = ppp.assignment_id
AND ppp.CHANGE_DATE =(SELECT MAX(ppp1.CHANGE_DATE)
FROM per_pay_proposals ppp1  
WHERE paaf.ASSIGNMENT_ID = ppp1.assignment_id
 )
 AND (ppp.CHANGE_DATE < :P_DATE  )
) utility,

(
Select  HOU.NAME  from 
pay_personal_payment_methods_f ppm,
pay_external_accounts pea,
hr_organization_units hou
WHERE 
 pea.EXTERNAL_ACCOUNT_ID(+) = ppm.EXTERNAL_ACCOUNT_ID
and ppm.ASSIGNMENT_ID(+) = paaf.ASSIGNMENT_ID
AND HOU.ATTRIBUTE3(+) = PEA.SEGMENT2
AND PPM.EFFECTIVE_START_DATE = (SELECT MAX(PPM1.EFFECTIVE_START_DATE)
FROM pay_personal_payment_methods_f ppm1,
pay_external_accounts pea1
WHERE 
 pea1.EXTERNAL_ACCOUNT_ID(+) = ppm1.EXTERNAL_ACCOUNT_ID
and ppm1.ASSIGNMENT_ID = paaf.ASSIGNMENT_ID
)
AND (PPM.EFFECTIVE_START_DATE < :P_DATE OR PPM.EFFECTIVE_END_DATE < :P_DATE)
)SALARY_BRANCH,

haou.name org,
pg.NAME grade,
pj.NAME job,
pap.NAME position,
hl.LOCATION_CODE location,

(select PPEI.PEI_INFORMATION1
   
from per_people_extra_info PPEI
where PPEI.PERSON_ID(+) = PAPF.PERSON_ID
AND PPEI.information_type(+) = 'BAFL_DA_SHOW_CAUSE'
and rownum=1
) DA_INITIATED,

(select PPE.PEI_ATTRIBUTE1 from per_people_extra_info PPE
where PPE.PERSON_ID(+) = PAPF.PERSON_ID
AND PPE.INFORMATION_TYPE(+) = 'BAFL_DA_DECISION_LETTER'
and rownum=1 )
DECISION,
  (   select TO_CHAR(b.segment1) 
        
from
           pay_cost_allocation_keyflex b 
    
WHERE haou.COST_ALLOCATION_KEYFLEX_ID = b.COST_ALLOCATION_KEYFLEX_ID 
AND 1=1
and haou.business_group_id = 81) COMPANY,

  (   select to_char(b.segment2) 
         
from
           pay_cost_allocation_keyflex b       
WHERE haou.COST_ALLOCATION_KEYFLEX_ID = b.COST_ALLOCATION_KEYFLEX_ID 
AND 1=1
and haou.business_group_id = 81) BUSINESS_SEGMENT,

  (   select  to_char(b.segment3) 
         
from
           pay_cost_allocation_keyflex b 
    
WHERE haou.COST_ALLOCATION_KEYFLEX_ID = b.COST_ALLOCATION_KEYFLEX_ID 
AND 1=1
and haou.business_group_id = 81) COST_CENTER,

  (   select 
       to_char(b.segment7) 
         
from
           pay_cost_allocation_keyflex b 
   
WHERE haou.COST_ALLOCATION_KEYFLEX_ID = b.COST_ALLOCATION_KEYFLEX_ID 
AND 1=1
and haou.business_group_id = 81)INTER_BRANCH,

(select pp.PHONE_NUMBER
 from per_phones pp
where pp.parent_id(+) = papf.person_id
and phone_type(+) = 'M' 
and rownum=1 )  cell_phone


 FROM
Per_all_people_f PAPF,
Per_all_assignments_f PAAF,
hr_all_organization_units haou,
per_grades pg,
per_jobs pj,
per_all_positions pap,
hr_locations hl

WHERE PAPF.PERSON_ID = PAAF.PERSON_ID
and haou.ORGANIZATION_ID = paaf.ORGANIZATION_ID
and pg.GRADE_ID(+) = paaf.GRADE_ID
and pj.JOB_ID(+) = paaf.JOB_ID
and PAAF.POSITION_ID = PAP.POSITION_ID(+)
and hl.LOCATION_ID(+) = paaf.LOCATION_ID

AND PAPF.EFFECTIVE_START_DATE = 
(
select max(papfc.EFFECTIVE_START_DATE) from per_all_people_f papfc
where papfc.PERSON_ID = papf.PERSON_ID
and PApfc.EFFECTIVE_START_DATE <:p_date 
) 
AND PAAF.EFFECTIVE_START_DATE = 
(select max(paaffc.EFFECTIVE_START_DATE) from per_all_assignments_f   paaffc
where paaffc.PERSON_ID = papf.PERSON_ID
and PAAFfc.EFFECTIVE_START_DATE <:p_date 
)


)
where 
--nvl(:p_date,sysdate) between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE
--and  EMPLOYEE_NUMBER =nvl(:emp_no,EMPLOYEE_NUMBER )
  nvl(ASSIGNMENT_NUMBER,Employee_number) = nvl(:emp_no,ASSIGNMENT_NUMBER)
and nvl(EMPLOYMENT_CATEGORY,'x') = nvl(nvl(:EMPLOYMENT_CATEGORY,EMPLOYMENT_CATEGORY),'x') 
AND org = NVL(:P_ORG,org)
and assignment_number is not null

