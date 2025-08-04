SELECT  DISTINCT 
CONCAT(SUBSTRING(PER.Cid, 1, 1), '-', SUBSTRING(PER.Cid, 2, 4), '-', SUBSTRING(PER.Cid, 6, 5), '-', SUBSTRING(PER.Cid, 11, 2), '-', SUBSTRING(PER.Cid, 13, 1)) AS 'cid'
, P.Code AS 'hn'
,	IIF(T.GenderKey = '-1' AND T.Code NOT IN ('101' , '324' , '102' , '325' , '104' , '278' , '105' , '121','321','323','338','819','900','1000','91','92','93','901') , '1', 
	IIF(T.Code IN ('105','277') AND T.GenderKey = '-2' , '2', 
	IIF(T.Code NOT IN ('105','277','102','325') AND T.GenderKey = '-2' , '3', 
	IIF(T.Code IN ('101','324') AND T.GenderKey = '-1' , '4',
	IIF(T.Code IN ('102','325') AND T.GenderKey = '-2' , '5',
	IIF(T.Code IN ('121','321','323','338','819','900','1000','91','92','93','901') AND T.GenderKey = '-1' , '6', '99')))))) AS 'title_code'
, TRIM(PER.FirstName) AS 'name'
, TRIM(PER.LastName) AS 'last_name'
, FORMAT(PER.BirthDT, 'yyyyMMdd') AS 'birth_date'
, IIF(G.Code = 'F', '2', IIF(G.Code = 'M', '1', '9')) AS 'sex_code'
,	IIF(N.Code IN ('000' , '1000','999','989'), '9',
	IIF(PER .NationalityKey IS NULL , '9', 
	IIF(N.Code IN ('099','094','095','198','199'), '1', 
	IIF(N.Code IN ('044','086','212','213','219','220'), '2', 
	IIF(N.Code = '056', '3', 
	IIF(N.Code IN ('057','089','257'), '4', 
	IIF(N.Code IN ('048','088','248','249'), '5', '8'))))))) AS 'nationality_code'
, TRIM(CONCAT(PER.AddressNo, ' ', IIF(PER.Road IS NULL, '', CONCAT('ถนน ', PER.Road)), ' ', IIF(PER.Soi IS NULL, '', CONCAT('ซอย ', PER.Soi)))) AS 'address_no'
, PER.Moo AS 'address_moo'
, IIF(LEN(TRIM(SD.Code)) != 6 OR SD.Code IS NULL, '999999', TRIM(SD.Code)) AS 'area_code'
, TRIM(CONCAT(PER.AddressNo, ' ', IIF(PER.Road IS NULL, '', CONCAT('ถนน ', PER.Road)), ' ' , IIF(PER.Soi IS NULL, '', CONCAT('ซอย ', PER.Soi)))) AS 'permanent_address_no'
, PER.Moo AS 'permanent_address_moo'
, IIF(LEN(TRIM(SD.Code)) != 6 OR SD.Code IS NULL, '999999' , TRIM(SD.Code)) AS 'permanent_area_code'
, FORMAT(de.DeadDT, 'yyyyMMdd') AS 'death_date'
, IIF(de.PdxIcd10Code LIKE 'C%', '1',IIF( de .PatientKey IS NULL , NULL , '9')) AS 'death_cause_code'
, PER.Email AS 'Email'
, CONCAT(PER.MobilePhone,' , ',PER.ContactPersonTelephone) AS 'telephone_1'
, DATEADD(DAY, 0, GETDATE()) AS 'send_date'

FROM dbo.Patient AS P 
	INNER JOIN dbo.Person AS PER ON PER.PersonKey = P.PatientKey
	LEFT OUTER JOIN dbo.Nationality N ON PER.NationalityKey = N.NationalityKey
	INNER JOIN dbo.Visit AS V ON V.PatientKey = P.PatientKey
	INNER JOIN dbo.ClinicVisit AS CV ON CV.VisitKey = V.VisitKey 
	INNER JOIN dbo.ServiceUnit AS SU ON CV.ServiceUnitKey = SU.ServiceUnitKey
	LEFT OUTER JOIN dbo.Title T ON PER.TitleKey = T .TitleKey
	LEFT OUTER JOIN dbo.Gender G ON PER.GenderKey = G.GenderKey
	LEFT OUTER JOIN dbo.THSubdistrict SD ON PER.THSubdistrictKey = SD.THSubdistrictKey
	LEFT OUTER JOIN dbo.DeathCert de ON de.PatientKey = p.PatientKey
WHERE      PER.BirthDT IS NOT NULL 
           AND CONVERT(VARCHAR, CV.DocDT, 103) = CONVERT(VARCHAR, DATEADD(DAY, -1, GETDATE()), 103)
           -- AND CONVERT(DATE, CV.DocDT, 103) BETWEEN '2025-07-26' AND GETDATE()
			  AND LEN(TRIM(PER.Cid)) = 13 
		     AND CV.ClinicVisitKey IN (
               SELECT DISTINCT cv2.ClinicVisitKey 
               FROM  dbo.CNDX dx2
               INNER JOIN dbo.ClinicVisit cv2 ON dx2.ClinicVisitKey = cv2.ClinicVisitKey 
                WHERE
                 CONVERT(VARCHAR, cv2.DocDT, 103) = CONVERT(VARCHAR, DATEADD(DAY, -1, GETDATE()), 103)  
                 -- CONVERT(DATE, cv2.DocDT, 103) BETWEEN '2025-07-26' AND GETDATE()
	AND dx2.DXTypeKey IN ( '1','2') 
   AND UPPER(dx2.Icd10Code) LIKE 'C%')