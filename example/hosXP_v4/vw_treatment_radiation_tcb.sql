SELECT * 
FROM (
    SELECT 
        SUBSTRING(p.cid, 1, 1) || '-' || 
        SUBSTRING(p.cid, 2, 4) || '-' || 
        SUBSTRING(p.cid, 6, 5) || '-' || 
        SUBSTRING(p.cid, 11, 2) || '-' || 
        SUBSTRING(p.cid, 13, 1) AS cid, 

        p.hn,        

        TO_CHAR(o.vstdate, 'YYYYMMDD') AS visit_date,
        '2' AS treatment_code,
        TO_CHAR(o.vstdate, 'YYYYMMDD') AS treatment_start_date,

        (
            SELECT UPPER(REPLACE(od2.icd10, '.', ''))
            FROM ovstdiag od2
            WHERE od2.vn = o.vn
              AND od2.diagtype = '1'
              AND UPPER(od2.icd10) LIKE 'C%'
            LIMIT 1
        ) AS icd10_code

    FROM ovst o
    LEFT JOIN ovstdiag od ON o.vn = od.vn
    LEFT JOIN patient_cancer_registeration pcr ON o.hn = pcr.hn
    LEFT JOIN patient p ON p.hn = o.hn

    WHERE o.vstdate = CURRENT_DATE

    AND (
        od.icd10 IN ('9221', '9222', '9223', '9224', '9225', '9226', '9227', '9241', '9231', '9232', '9233', '9359')
        OR o.vn IN (
            SELECT vn 
            FROM ovstoprt 
            WHERE vn = o.vn 
              AND icd9cm IN ('9221', '9222', '9223', '9224', '9225', '9226', '9227', '9241', '9231', '9232', '9233', '9359')
        )
    )
) AS dat
WHERE icd10_code IS NOT NULL;
