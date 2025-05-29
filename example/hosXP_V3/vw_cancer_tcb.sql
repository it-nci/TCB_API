SELECT 
    DISTINCT 
    (CASE 
            WHEN pty.pcode in ('A1','A9','94') THEN '1'
            WHEN pty.pcode in ('B1','B2','B3','B4','B5','L1','L2','L3','L4','L5','L6','O1','O2','O3','O4','O5','UB','Z3') THEN '2'
            WHEN pty.pcode in ('A7') THEN '3'
            WHEN pty.pcode in ('A3','A5','AA','AB','AC','AD','AE','AF','AG','AH','AJ','AK','AL','UC') THEN '4'
            ELSE '9'
    END) AS finance_support_code,
    pcr.patient_cancer_last_visit_date AS clinic_visit,
    CONCAT(SUBSTRING(p.cid, 1, 1), '-', SUBSTRING(p.cid, 2, 4), '-', SUBSTRING(p.cid, 6, 5), '-', SUBSTRING(p.cid, 11, 2), '-', SUBSTRING(p.cid, 13, 1)) AS cid, 
    p.hn,
    DATE_FORMAT(o.vstdate, "%Y%m%d") AS visit_date,
    '' AS diagnosis_code,
    '' AS morphology,
    '3' AS behaviour_code,
    pcr.cancer_grade_id AS grade,
    '' AS stage,
    pcr.t_value AS t, 
    pcr.n_value AS n, 
    pcr.m_value AS m,
    '' AS recurrent,
    '' AS recurrent_date,
    '' AS clinical_summary, 
    (select upper(replace(od.icd10, '.', ''))  
     from ovstdiag od 
     where od.vn = o.vn
       and od.diagtype = '1' 
       and upper(od.icd10) LIKE 'C%') AS icd10_code,
     DATE_FORMAT(DATE(NOW()), "%Y%m%d") AS send_date
FROM ovst o
LEFT OUTER JOIN patient p ON p.hn = o.hn
LEFT OUTER JOIN pttype pty ON pty.pttype = o.pttype
LEFT OUTER JOIN patient_cancer_registeration pcr ON pcr.hn = o.hn
WHERE o.vstdate = CURDATE()
    AND length(TRIM(p.cid)) = 13
    AND o.vn IN (
        select distinct o.vn from ovstdiag 
				where o.vn = vn and vstdate = CURDATE()
				and diagtype = '1' and upper(icd10) like 'C%')
ORDER BY o.vstdate DESC;