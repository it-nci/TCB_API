SELECT * 
FROM (
SELECT CONCAT(SUBSTRING(p.cid, 1, 1), '-', SUBSTRING(p.cid, 2, 4), '-', SUBSTRING(p.cid, 6, 5), '-', SUBSTRING(p.cid, 11, 2), '-', SUBSTRING(p.cid, 13, 1)) AS cid, 
        p.hn,
        DATE_FORMAT(v.vstdate, "%Y%m%d") AS visit_date,
        '3' AS treatment_code,
        DATE_FORMAT(v.vstdate, "%Y%m%d") AS treatment_start_date,
        od.icd10 AS icd10_code
FROM vn_stat v
LEFT OUTER JOIN ovstdiag od ON od.vn=v.vn
LEFT OUTER JOIN patient p ON p.hn = v.hn
WHERE v.vstdate = CURDATE()
and `od`.`diagtype` = '1' 
and ucase(`od`.`icd10`) like 'C%' 
AND (v.op0 IN ("9925", "9928", "9929")
OR v.op1 IN ("9925", "9928", "9929")
OR v.op2 IN ("9925", "9928", "9929")
OR v.op3 IN ("9925", "9928", "9929")
OR v.op4 IN ("9925", "9928", "9929")
OR v.op5 IN ("9925", "9928", "9929"))
) DAT 
WHERE icd10_code IS NOT NULL;