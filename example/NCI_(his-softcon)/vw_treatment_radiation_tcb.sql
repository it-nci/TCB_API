SELECT * 
FROM (
    SELECT 
        CONCAT(
            SUBSTRING(PER.Cid, 1, 1), '-', 
            SUBSTRING(PER.Cid, 2, 4), '-', 
            SUBSTRING(PER.Cid, 6, 5), '-', 
            SUBSTRING(PER.Cid, 11, 2), '-', 
            SUBSTRING(PER.Cid, 13, 1)
        ) AS cid, 
        FORMAT(CV.DocDT, 'yyyyMMdd') AS visit_date,  
        '2' AS treatment_code, 
        FORMAT(CV.DocDT, 'yyyyMMdd') AS treatment_start_date, 
        (
            SELECT UPPER(REPLACE(D.Icd10Code, '.', ''))  
            FROM CNDX D 
            WHERE D.ClinicVisitKey = CV.ClinicVisitKey 
              AND D.DXTypeKey = '1' 
              AND UPPER(D.Icd10Code) LIKE 'C%'
        ) AS icd10_code 
    FROM 
        ClinicVisit CV 
        INNER JOIN Patient P ON CV.PatientKey = P.PatientKey 
        INNER JOIN Person PER ON PER.PersonKey = P.PatientKey 
    WHERE 
        CV.DischargeDT IS NOT NULL  
        AND CONVERT(VARCHAR, CV.DocDT, 112) = CONVERT(VARCHAR, DATEADD(DAY, 0, GETDATE()), 112)  
        AND CV.ServiceUnitKey IN (9001222,9001223) 
        AND CV.CCKey IN (10121341,10121342,10121345,10121352) 
) DAT 
WHERE icd10_code IS NOT NULL;