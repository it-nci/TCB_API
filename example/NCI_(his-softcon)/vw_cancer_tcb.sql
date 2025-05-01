WITH cv (patientkey, MainVIsitMCKey, DocDT, CLinicvisitkey, ICD10, stage, t, n, m, extension) AS (
  SELECT DISTINCT
    cv.patientkey
    ,
    cv.MainVisitMCKey
    ,
    cv.DocDT
    ,
    cv.ClinicVisitKey
    ,
    UPPER(REPLACE(D.Icd10Code, '.', '')) 'icd10_code',
    CS.Code 'stage',
    ct.CancerTumorCode 't',
    cn.CancerNodeCode 'n',
    cm.CancerMetaCode 'm',
  CASE
      
      WHEN cm.CancerMetaCode = '1' THEN
      '5 Distant metastasis' 
      WHEN cn.CancerNodeCode  <> '0' THEN
      '4 Regional lymph nodes' 
      WHEN (ct.CancerTumorCode LIKE '1%' OR ct.CancerTumorCode LIKE '2%') THEN
      '2 Localize' 
      WHEN (ct.CancerTumorCode LIKE '3%' OR ct.CancerTumorCode LIKE '4%') THEN
      '3 Direct extension' ELSE '9 Not known' 
    END AS extension 
  FROM
    dbo.CNDX D
    LEFT JOIN dbo.CancerStage CS ON D.CancerStageKey = CS.CancerStageKey
    LEFT JOIN dbo.CancerTumor Ct ON D.CancerTumorCode = ct.CancerTumorCode
    LEFT JOIN dbo.CancerNode Cn ON D.CancerNodeCode = cn.CancerNodeCode
    LEFT JOIN dbo.CancerMeta cm ON D.CancerMetaCode = cm.CancerMetaCode
    LEFT JOIN (
      SELECT DISTINCT
        cv2.VisitKey,
        cv2.patientkey
        ,
        cv2.ClinicVisitKey
        ,
        cv2.MainVisitMCKey
        ,
        MAX(cv2.DocDT) 'DocDT' 
      FROM
        dbo.ClinicVisit cv2 
      WHERE
        cv2.ClinicVisitSKey <> '32' 
      GROUP BY
        cv2.visitkey,
        cv2.ClinicVisitKey,
        cv2.patientkey,
    cv2.MainVisitMCKey) cv ON cv.ClinicVisitKey = D.ClinicVisitKey 
  WHERE
    CS.Code IS NOT NULL 
    AND cv.PatientKey IS NOT NULL 
    AND D.DXTypeKey = '1' 
    AND D.IsMainPdx = '1' 
AND D.Icd10Code LIKE 'C%'),
patho (patientkey, patho_sent_date, patho_approve_date, morpho, behavior_code, grade_code, topo) AS (
  SELECT
    pt.PatientKey
    ,
    format (la.SpecimenReceiveDT, 'yyyyMMdd') 'patho_sent_date',
    format (la.ApproveDT, 'yyyyMMdd') 'patho_approve_date',
    concat (lhm.code, ' ', lhm.ENName) 'morpho',
    concat (lbh.code, ' ', lbh.ENName) 'behavior_code',
    concat (lhg.code, ' ', lhg.Name) 'grade_code',
    concat (lht.code, ' ', lht.Name) 'topo' 
  FROM
    dbo.LabRequest AS la
    LEFT OUTER JOIN dbo.LabResult AS lr ON lr.LabRequestKey = la.LabRequestKey
    LEFT OUTER JOIN dbo.LabHistoMorpho AS lhm ON lhm.LabHistoMorphoKey = lr.LabHistoMorphoKey
    LEFT OUTER JOIN dbo.LabMethod AS lm ON lm.LabMethodKey = lr.LabMethodKey
    LEFT OUTER JOIN dbo.LabHistoTopo AS lht ON lht.LabHistoTopoKey = lr.LabHistoTopoKey
    LEFT JOIN dbo.LabHistoBehavior lbh ON lbh.LabHistoBehaviorKey = lr.LabHistoBehaviorKey
    LEFT OUTER JOIN dbo.LabRequestHeader AS lrh ON lrh.LabRequestHeaderKey = la.LabRequestHeaderKey
    LEFT JOIN dbo.Patient pt ON pt.PatientKey = lrh.PatientKey
    LEFT JOIN dbo.LabHistoGrade lhg ON lhg.LabHistoGradeKey = lr.LabHistoGradeKey 
  WHERE
    (lm.LabMethodKey BETWEEN '10119787' AND '10119787') --select only pathology test
    
    AND (la.LN IS NOT NULL) 
    AND (la.LineNum = '1') 
    AND (lbh.code BETWEEN 2 AND 3) -- select only malignant or saitu
) SELECT DISTINCT
CONCAT(SUBSTRING(PER.Cid, 1, 1), '-', SUBSTRING(PER.Cid, 2, 4), '-', SUBSTRING(PER.Cid, 6, 5), '-', SUBSTRING(PER.Cid, 11, 2), '-', SUBSTRING(PER.Cid, 13, 1)) AS cid,
FORMAT (cv.DocDT, 'yyyyMMdd') AS visit_date,
dx_date.first_cancer_visit,
dx_date.last_cancer_visit,
cv.ICD10 'diagnosis-code',
patho.morpho,
patho.behavior_code,
patho.grade_code,
patho.patho_approve_date,
cv.stage,
cv.t,
cv.n,
cv.m,
cv.extension,
FORMAT (cv.DocDT, 'yyyyMMdd') AS tnm_date,
IIF (cv.stage = '8', '1', '') AS recurrent,
IIF (cv.stage = '8', FORMAT (cv.DocDT, 'yyyyMMdd'), '') AS recurrent_date,
CASE
    
    WHEN M.MCKey = '12' THEN
    '1' 
    WHEN M.MCKey = '76' THEN
    '4' 
    WHEN M.MCKey = '1' THEN
    '2' 
    WHEN M.MCKey = '4' THEN
    '4' 
    WHEN M.MCKey = '31' THEN
    '2' 
    WHEN M.MCKey = '6' THEN
    '3' 
    WHEN M.MCKey = '33' THEN
    '2' 
    WHEN M.MCKey = '66' THEN
    '4' 
    WHEN M.MCKey = '82' THEN
    '4' 
    WHEN M.MCKey = '32' THEN
    '2' 
    WHEN M.MCKey = '7' THEN
    '2' 
    WHEN M.MCKey = '101' THEN
    '4' 
    WHEN M.MCKey = '2' THEN
    '2' 
    WHEN M.MCKey = '15' THEN
    '2' 
    WHEN M.MCKey = '10' THEN
    '4' 
    WHEN M.MCKey = '78' THEN
    '3' 
    WHEN M.MCKey = '19' THEN
    '2' ELSE '9' 
  END AS finance_support_code,
  DATEADD(DAY, 0, GETDATE()) AS send_date 
FROM
  dbo.Patient AS P
  LEFT JOIN dbo.Person AS PER ON PER.PersonKey = P.PatientKey
  LEFT JOIN dbo.Visit AS V ON V.PatientKey = P.PatientKey
  LEFT JOIN dbo.Title T ON PER.TitleKey = T.TitleKey
  LEFT JOIN cv ON cv.PatientKey = P.PatientKey
  INNER JOIN dbo.VisitMC VMC ON VMC.VisitMCKey = CV.MainVisitMCKey
  INNER JOIN dbo.PatientMC PMC ON PMC.PatientMCKey = VMC.PatientMCKey
  INNER JOIN dbo.MC M ON M.MCKey = PMC.MCKey
  LEFT JOIN (
    SELECT DISTINCT
      cv.PatientKey ,
      FORMAT (MIN(cv.docdt), 'yyyyMMdd') 'first_cancer_visit',
      FORMAT (MAX(cv.docdt), 'yyyyMMdd') 'Last_cancer_visit' 
    FROM
      dbo.ClinicVisit cv
      LEFT JOIN dbo.CNDX dx ON dx.ClinicVisitKey = cv.ClinicVisitKey 
    WHERE
      cv.ClinicVisitSKey <> 32 
      AND dx.Icd10Code LIKE 'C%' 
    GROUP BY
  cv.PatientKey) dx_date ON dx_date.PatientKey = p.PatientKey
  LEFT JOIN patho ON patho.patientkey = p.PatientKey 
WHERE
  CONVERT (VARCHAR, CV.DocDT, 103) = CONVERT (VARCHAR, DATEADD(DAY, 0, GETDATE()), 103) 
  AND LEN(TRIM (PER.Cid)) = 13 
  AND CV.ClinicVisitKey IN (
    SELECT DISTINCT
      dbo.ClinicVisit.ClinicVisitKey 
    FROM
      dbo.CNDX
      INNER JOIN dbo.ClinicVisit ON CNDX.ClinicVisitKey = ClinicVisit.ClinicVisitKey 
    WHERE
      CONVERT (VARCHAR, ClinicVisit.DocDT, 103) = CONVERT (VARCHAR, DATEADD(DAY, 0, GETDATE()), 103) 
      AND CNDX.DXTypeKey = '1' 
  AND UPPER(CNDX.Icd10Code) LIKE 'C%')