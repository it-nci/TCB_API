SELECT * 
FROM (
    SELECT 
        CONCAT(SUBSTRING(p.cid, 1, 1), '-', SUBSTRING(p.cid, 2, 4), '-', SUBSTRING(p.cid, 6, 5), '-', SUBSTRING(p.cid, 11, 2), '-', SUBSTRING(p.cid, 13, 1)) AS cid, 
        p.hn,
        DATE_FORMAT(o.vstdate, "%Y%m%d") AS visit_date,
        '2' AS treatment_code,
        DATE_FORMAT(pcr.patient_cancer_first_diag_cancer_date, "%Y%m%d") AS treatment_start_date,
        (select upper(replace(od.icd10, '.', ''))  
          from ovstdiag od 
          where od.vn = o.vn
          and od.diagtype = '1' 
          and upper(od.icd10) LIKE 'C%') AS icd10_code
    FROM 
        ovst o
				LEFT OUTER JOIN ovstdiag od ON o.vn = od.vn
        LEFT OUTER JOIN patient_cancer_registeration pcr ON o.hn = pcr.hn
        LEFT OUTER JOIN patient p ON p.hn = o.hn
    WHERE o.vstdate = CURDATE()
		
		AND (od.icd10 IN ("9221", "9222", "9223", "9224", "9225", "9226", "9227", "9241", "9231", "9232", "9233", "9359")
			or o.vn in (select vn from ovstoprt where vn = o.vn and icd9cm in ("9221", "9222", "9223", "9224", "9225", "9226", "9227", "9241", "9231", "9232", "9233", "9359")))
			
) DAT 
WHERE icd10_code IS NOT NULL;