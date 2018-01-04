SELECT   pap.person_id,
         pap.full_name,
         paa.assignment_id,
         pap.last_name,
         pap.first_name,
         apps.hr_general.decode_lookup ('TITLE', pap.title) title,
         ppt.user_person_type person_type,
         ppt.system_person_type,
         pap.original_date_of_hire,
         ppos.date_start perid_start_date,
         ppos.actual_termination_date,
         flv.meaning leaving_reason_meaning,
         ppos.leaving_reason,
         pap.employee_number,
         pap.national_identifier,
         pap.date_of_birth,
         pap.town_of_birth,
         apps.hr_general.decode_lookup ('MAR_STATUS', pap.marital_status) marital_status,
         pap.region_of_birth,
         apps.hr_general.decode_lookup ('NATIONALITY', pap.nationality) nationality,
         DECODE (pap.sex, 'M', '–ﬂ—', '«‰ÀÏ') sex,
         pap.country_of_birth,
         ftv.territory_short_name country_of_brith_meaning,
         apps.hr_general.decode_lookup ('REGISTERED_DISABLED', pap.registered_disabled_flag ) registered_disable,
         pap.effective_start_date effective_start_date_emp,
         pap.effective_end_date effective_end_date_emp,
         paa.organization_id,
         haou.NAME organization_dept,
         ppg.segment1 paid_by_group,
         ppg.segment2 union1,
         ppg.segment3 currency,
         ppg.segment4 tax_paid_by_company,
         ppg.segment5 social_security,
         paa.job_id,
         ppg.segment6 employee_type1,
         pj.NAME job_det,
         SUBSTR (pj.NAME, INSTR (pj.NAME, '.', -1, 1) + 1) job_no,
         SUBSTR (pj.NAME, INSTR (pj.NAME, '.', 1, 4) + 1,NVL (  INSTR (pj.NAME, '.', 1, 5) - INSTR (pj.NAME, '.', 1, 4)  - 1, 0 ) ) job_title,
         papo.NAME POSITION,
         pg.NAME grade ,
         SUBSTR (pg.NAME, INSTR (pg.NAME, '.') + 1) grade,
         SUBSTR (pj.NAME, -2, 2) job_mar,
         SUBSTR (pg.NAME, 1, INSTR (pg.NAME, '.', 1) - 1) gader,
         papf.payroll_name,
         hla.location_code,
         psstt.user_status assignment_status,
         paa.assignment_number,
         paa.assignment_type,
         employment_category,
         DECODE (paa.assignment_type,
                 'E', apps.hr_general.decode_lookup ('EMP_CAT', paa.employment_category ),
                 'C', apps.hr_general.decode_lookup ('CWK_ASG_CATEGORY', paa.employment_category )
                ) assignment_category,
         apps.hr_general.decode_lookup ('EMPLOYEE_CATG', paa.employee_category) employee_category,
         ppb.NAME salary_bases,
         paps.full_name sup_name,
         paps.employee_number worker_number,
         paa.effective_start_date effective_start_date_asg,
         paa.effective_end_date effective_end_date_asg,
         ptu.effective_start_date effective_start_date_pusage,
         ptu.effective_end_date effective_end_date_pusage,
         papf.effective_start_date effective_start_date_pay,
         NVL (cost_ff.segment2, '0000') gl_cost_centre,
         papf.effective_end_date effective_end_date_pay,
         paa.primary_flag,
         pap.attribute1 arabic_firstname,
         paa.probation_unit,
         pap.attribute2 arabic_middle_name,
         pap.attribute3 arabic_last_name,
         pap.attribute8 arabic_nationality,
         pap.attribute4 blood_group,
         pap.attribute5 ss_no,
         pap.attribute10 ss_start_date,
         pap.attribute6 first_ser_start_date,
         paa.probation_period,
         pap.attribute9 no_children,
         pap.attribute11 religion,
         NULL null_col

    FROM apps.per_all_people_f pap,
         apps.per_all_assignments_f paa,
         apps.per_person_type_usages_f ptu,
         apps.per_person_types ppt,
         apps.fnd_territories_vl ftv,
         apps.hr_all_organization_units haou,
         apps.pay_people_groups ppg,
         apps.per_jobs pj,
         apps.per_grades pg,
         apps.per_all_positions papo,
         apps.pay_all_payrolls_f papf,
         apps.hr_locations_all hla,
         apps.per_assignment_status_types_tl psstt,
         apps.per_pay_bases ppb,
         apps.per_people_x paps,
         apps.per_periods_of_service ppos,
         apps.fnd_lookup_values flv,
         apps.pay_cost_allocation_keyflex cost_ff

   WHERE pap.person_id = paa.person_id
     AND ptu.person_id = pap.person_id
     AND ppt.person_type_id = ptu.person_type_id
     AND ftv.territory_code(+) = pap.country_of_birth
     AND haou.organization_id = paa.organization_id
     AND ppg.people_group_id(+) = paa.people_group_id
     AND pj.job_id(+) = paa.job_id
     AND papo.position_id(+) = paa.position_id
     AND pg.grade_id(+) = paa.grade_id
     AND papf.payroll_id(+) = paa.payroll_id
     AND hla.location_id(+) = paa.location_id
     AND psstt.assignment_status_type_id = paa.assignment_status_type_id
     AND ppb.pay_basis_id(+) = paa.pay_basis_id
     AND paps.person_id(+) = paa.supervisor_id
     AND ppos.person_id = pap.person_id
     AND flv.lookup_type(+) = 'LEAV_REAS'
     AND flv.lookup_code(+) = ppos.leaving_reason
     AND cost_ff.cost_allocation_keyflex_id(+) = haou.cost_allocation_keyflex_id
     AND psstt.user_status = 'Active Assignment'
     AND SYSDATE BETWEEN paa.effective_start_date AND paa.effective_end_date
     AND SYSDATE BETWEEN pap.effective_start_date AND pap.effective_end_date
     AND SYSDATE BETWEEN ptu.effective_start_date AND ptu.effective_end_date
     AND SYSDATE BETWEEN papf.effective_start_date AND papf.effective_end_date
     AND PAP.EMPLOYEE_NUMBER=1001
ORDER BY TO_NUMBER (employee_number)
