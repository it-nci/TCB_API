SELECT DISTINCT
  CONCAT (
    SUBSTRING(PER.Cid, 1, 1),
    '-',
    SUBSTRING(PER.Cid, 2, 4),
    '-',
    SUBSTRING(PER.Cid, 6, 5),
    '-',
    SUBSTRING(PER.Cid, 11, 2),
    '-',
  SUBSTRING(PER.Cid, 13, 1)) AS cid,
  P.code AS hn,
  IIF (
    T.Name = 'นาย',
    '1',
  IIF (T.Name = 'นาง', '2', IIF (T.Name = 'นางสาว', '3', '99'))) AS title_code,
  TRIM (PER.FirstName) AS name,
  TRIM (PER.LastName) AS last_name,
  FORMAT (PER.BirthDT, 'yyyyMMdd') AS birth_date,
  IIF (G.Code = 'F', '2', '1') AS sex_code,
  IIF (
    N.Code IS NULL,
    '9',
    IIF (
      N.Code = '099',
      '1',
      IIF (
        N.Code = '044',
        '2',
        IIF (
          N.Code = '056',
          '3',
        IIF (N.Code = '057', '4', IIF (N.Code = '048', '5', '8')))))) AS nationality_code,
  TRIM (
    CONCAT (
      PER.AddressNo,
      ' ',
      IIF (PER.Road IS NULL, '', CONCAT ('ถนน ', PER.Road)),
      ' ',
    IIF (PER.Soi IS NULL, '', CONCAT ('ซอย ', PER.Soi)))) AS address_no,
  PER.Moo AS address_moo,
  IIF (LEN(TRIM (SD.Code)) != 6 OR SD.Code IS NULL, '999999', TRIM (SD.Code)) AS area_code,
  TRIM (
    CONCAT (
      PER.AddressNo,
      ' ',
      IIF (PER.Road IS NULL, '', CONCAT ('ถนน ', PER.Road)),
      ' ',
    IIF (PER.Soi IS NULL, '', CONCAT ('ซอย ', PER.Soi)))) AS permanent_address_no,
  PER.Moo AS permanent_address_moo,
  IIF (LEN(TRIM (SD.Code)) != 6 OR SD.Code IS NULL, '999999', TRIM (SD.Code)) AS permanent_area_code,
  FORMAT (de.DeadDT, 'yyyyMMdd') AS death_date,
  de.PdxIcd10Code AS death_cause_code,
  PER.Email AS Email,
  PER.MobilePhone AS telephone_1,
  DATEADD(DAY, 0, GETDATE()) AS send_date 
FROM
  dbo.Patient AS P
  INNER JOIN dbo.Person AS PER ON PER.PersonKey = P.PatientKey
  LEFT OUTER JOIN dbo.Nationality N ON PER.NationalityKey = N.NationalityKey
  INNER JOIN dbo.Visit AS V ON V.PatientKey = P.PatientKey
  INNER JOIN dbo.ClinicVisit AS CV ON CV.VisitKey = V.VisitKey
  INNER JOIN dbo.ServiceUnit AS SU ON CV.ServiceUnitKey = SU.ServiceUnitKey
  LEFT OUTER JOIN dbo.Title T ON PER.TitleKey = T.TitleKey
  LEFT OUTER JOIN dbo.Gender G ON PER.GenderKey = G.GenderKey
  LEFT OUTER JOIN dbo.THSubdistrict SD ON PER.THSubdistrictKey = SD.THSubdistrictKey
  LEFT OUTER JOIN dbo.DeathCert de ON de.PatientKey = p.PatientKey 
WHERE
  PER.BirthDT IS NOT NULL 
  AND CONVERT (VARCHAR, CV.DocDT, 103) = CONVERT (VARCHAR, DATEADD(DAY, 0, GETDATE()), 103) ---query only pt data with visit on the N day of date sendadata
  
  AND LEN(TRIM (PER.Cid)) = 13 
  AND CV.ClinicVisitKey IN (
    SELECT DISTINCT
      cv2.ClinicVisitKey 
    FROM
      dbo.CNDX dx2
      INNER JOIN dbo.ClinicVisit cv2 ON dx2.ClinicVisitKey = cv2.ClinicVisitKey 
    WHERE
      CONVERT (VARCHAR, cv2.DocDT, 103) = CONVERT (VARCHAR, DATEADD(DAY, 0, GETDATE()), 103) 
      AND dx2.DXTypeKey = '1' 
  AND UPPER(dx2.Icd10Code) LIKE 'C%' 
  AND cv2.ClinicVisitSKey <> '32')