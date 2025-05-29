SELECT DISTINCT
    CASE 
        WHEN pty.pcode IN ('A1','A9','94') THEN '1'
        WHEN pty.pcode IN ('B1','B2','B3','B4','B5','L1','L2','L3','L4','L5','L6','O1','O2','O3','O4','O5','UB','Z3') THEN '2'
        WHEN pty.pcode IN ('A7') THEN '3'
        WHEN pty.pcode IN ('A3','A5','AA','AB','AC','AD','AE','AF','AG','AH','AJ','AK','AL','UC') THEN '4'
        ELSE '9'
    END AS finance_support_code,
    pcr.patient_cancer_last_visit_date AS clinic_visit,
    SUBSTRING(p.cid, 1, 1) || '-' || 
    SUBSTRING(p.cid, 2, 4) || '-' || 
    SUBSTRING(p.cid, 6, 5) || '-' || 
    SUBSTRING(p.cid, 11, 2) || '-' || 
    SUBSTRING(p.cid, 13, 1) AS cid,
    p.hn,
    TO_CHAR(o.vstdate, 'YYYYMMDD') AS visit_date,
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
    (
        SELECT UPPER(REPLACE(od.icd10, '.', '')) 
        FROM ovstdiag od 
        WHERE od.vn = o.vn 
          AND od.diagtype = '1' 
          AND UPPER(od.icd10) LIKE 'C%' 
        LIMIT 1
    ) AS icd10_code,
    TO_CHAR(CURRENT_DATE, 'YYYYMMDD') AS send_date
FROM ovst o
LEFT JOIN patient p ON p.hn = o.hn
LEFT JOIN pttype pty ON pty.pttype = o.pttype
LEFT JOIN patient_cancer_registeration pcr ON pcr.hn = o.hn
WHERE o.vstdate = CURRENT_DATE
  AND LENGTH(TRIM(p.cid)) = 13
  AND EXISTS (
      SELECT 1 FROM ovstdiag od
      WHERE od.vn = o.vn 
        AND od.vstdate = CURRENT_DATE
        AND od.diagtype = '1'
        AND UPPER(od.icd10) LIKE 'C%'
  )
ORDER BY o.vstdate DESC;
