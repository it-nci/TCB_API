WITH cv (patientkey,MainVIsitMCKey,DocDT,CLinicvisitkey,ICD10,recurrent,stage_code,t,n,m,extension_code)
AS (SELECT DISTINCT
		cv.patientkey
		,cv.MainVisitMCKey
		,cv.DocDT
		,cv.ClinicVisitKey
		,UPPER(REPLACE(D.Icd10Code, '.', '')) 'icd10_code'
		,IIF( CS.Code = '8', '1', NULL ) AS 'recurrent' 
		,CASE 
        WHEN CS.CancerStageKey = '1' THEN '1'
        WHEN CS.CancerStageKey = '2' THEN '2'
        WHEN CS.CancerStageKey = '3' THEN '3'
        WHEN CS.CancerStageKey = '4' THEN '4'
        WHEN CS.CancerStageKey = '5' THEN '9'
        WHEN CS.CancerStageKey = '6' THEN '10' 
        WHEN CS.CancerStageKey = '7' THEN '13' 
        WHEN CS.CancerStageKey = '8' THEN '23' 
        WHEN CS.CancerStageKey = '9' THEN '30' 
        WHEN CS.CancerStageKey = '10' THEN '31'
        WHEN CS.CancerStageKey = '11' THEN '32'
        WHEN CS.CancerStageKey = '12' THEN '16'
        WHEN CS.CancerStageKey = '13' THEN '24'
        WHEN CS.CancerStageKey = '14' THEN '40'
        WHEN CS.CancerStageKey = '15' THEN '43'
        WHEN CS.CancerStageKey = '16' THEN '44' 
        WHEN CS.CancerStageKey = '17' THEN '20' 
        WHEN CS.CancerStageKey = '18' THEN '11' 
        WHEN CS.CancerStageKey = '19' THEN '12' 
        WHEN CS.CancerStageKey = '20' THEN '14'
        WHEN CS.CancerStageKey = '21' THEN '15'
        WHEN CS.CancerStageKey = '22' THEN '21'
        WHEN CS.CancerStageKey = '23' THEN '22'
        WHEN CS.CancerStageKey = '24' THEN '30'
        WHEN CS.CancerStageKey = '25' THEN '30'
        WHEN CS.CancerStageKey = '26' THEN '10' 
        WHEN CS.CancerStageKey = '27' THEN '33' 
        WHEN CS.CancerStageKey = '29' THEN '34' 
        WHEN CS.CancerStageKey = '30' THEN '41'
        WHEN CS.CancerStageKey = '31' THEN '42' 
        WHEN CS.CancerStageKey = '33' THEN '13' 
        WHEN CS.CancerStageKey = '34' THEN '0'
        ELSE '9'
    	END AS 'stage_code' 
		,ct.CancerTumorCode 't'
		,cn.CancerNodeCode 'n'
		,cm.CancerMetaCode 'm'
		,CASE 
 			WHEN cm.CancerMetaCode IN ('1','1a','1b','1c','2c','cm1','pm1') THEN '5' 
 			WHEN cn.CancerNodeCode IN ('1','1a','1b','1c','1mi','2','2a','2b','2c','2mi','3','c1') THEN '4' 
 			WHEN (ct.CancerTumorCode LIKE '1%' OR ct.CancerTumorCode LIKE '2%' OR ct.CancerTumorCode LIKE 'C1%' OR ct.CancerTumorCode LIKE 'C2%' OR ct.CancerTumorCode IN ('P1','P2','PT1','PT2')) THEN '2' 
 			WHEN (ct.CancerTumorCode LIKE '3%' OR ct.CancerTumorCode LIKE '4%' OR ct.CancerTumorCode LIKE 'C3%' OR ct.CancerTumorCode LIKE 'C4%' OR ct.CancerTumorCode IN ('P3','P4','PT3','PT4')) THEN '3' 
 			WHEN ct.CancerTumorCode = 'is' THEN '1'
 			ELSE '9' 
 		END AS 'extension_code'
	FROM dbo.CNDX D 
		LEFT JOIN dbo.CancerStage CS ON D.CancerStageKey = CS.CancerStageKey 
		LEFT JOIN dbo.CancerTumor Ct on D.CancerTumorCode = ct.CancerTumorCode
		LEFT JOIN dbo.CancerNode Cn on D.CancerNodeCode = cn.CancerNodeCode
		LEFT JOIN dbo.CancerMeta cm on D.CancerMetaCode = cm.CancerMetaCode
		LEFT JOIN (SELECT DISTINCT cv2.VisitKey,cv2.patientkey,cv2.ClinicVisitKey,cv2.MainVisitMCKey,MAX(cv2.DocDT) 'DocDT'
						FROM dbo.ClinicVisit cv2 
						WHERE cv2.ClinicVisitSKey <> '32' 
						GROUP BY cv2.visitkey,cv2.ClinicVisitKey,cv2.patientkey,cv2.MainVisitMCKey) cv ON cv.ClinicVisitKey = D.ClinicVisitKey
	WHERE CS.Code is not null 
      AND cv.PatientKey is not null
      AND D.DXTypeKey = '1' 
	  	AND D.IsMainPdx = '1'
	  	AND D.Icd10Code like 'C%')

, patho (patientkey,patho_sent_date,patho_approve_date,morpho,behavior_code,grade_code,topo_code)
AS (SELECT pt.PatientKey
		,FORMAT(la.SpecimenReceiveDT,'yyyyMMdd')'patho_sent_date'
		,FORMAT(la.ApproveDT,'yyyyMMdd')'patho_approve_date'
		,lhm.note AS 'morpho'
		,lbh.code AS 'behavior_code'
		,lhg.code AS 'grade_code'
		,lht.code AS 'topo_code'
	FROM dbo.LabRequest AS la 
		LEFT OUTER JOIN dbo.LabResult AS lr ON lr.LabRequestKey = la.LabRequestKey 
		LEFT OUTER JOIN dbo.LabHistoMorpho AS lhm ON lhm.LabHistoMorphoKey = lr.LabHistoMorphoKey 
		LEFT OUTER JOIN dbo.LabMethod AS lm ON lm.LabMethodKey = lr.LabMethodKey 
		LEFT OUTER JOIN dbo.LabHistoTopo AS lht ON lht.LabHistoTopoKey = lr.LabHistoTopoKey 
		LEFT JOIN dbo.LabHistoBehavior lbh ON lbh.LabHistoBehaviorKey = lr.LabHistoBehaviorKey
		LEFT OUTER JOIN dbo.LabRequestHeader AS lrh ON lrh.LabRequestHeaderKey = la.LabRequestHeaderKey
		LEFT JOIN dbo.Patient pt ON pt.PatientKey = lrh.PatientKey
		LEFT JOIN dbo.LabHistoGrade lhg ON lhg.LabHistoGradeKey = lr.LabHistoGradeKey
	WHERE (lm.LabMethodKey BETWEEN '10119787' AND '10119787')
	   AND (la.LN IS NOT NULL) 
		AND (la.LineNum ='1')  
		AND (lbh.code BETWEEN 2 AND 3) 
	) 
SELECT DISTINCT 
	CONCAT(SUBSTRING(PER.Cid, 1, 1), '-', SUBSTRING(PER.Cid, 2, 4), '-',
	SUBSTRING(PER.Cid, 6, 5), '-', SUBSTRING(PER.Cid, 11, 2), '-', SUBSTRING(PER.Cid, 13, 1)) AS 'cid', 
	FORMAT(cv.DocDT, 'yyyyMMdd') AS 'visit_date',  
	-- dx_date.first_cancer_visit,
	-- dx_date.last_cancer_visit,
	cv.ICD10 AS 'icd10_code',
		CASE 
        WHEN M.MCKey = '12' THEN '1'
        WHEN M.MCItemGroupKey = '7' THEN '1'
        WHEN M.MCItemGroupKey = '4' THEN '2'
        WHEN M.MCItemGroupKey = '6' THEN '3'
        WHEN M.MCItemGroupKey = '5' THEN '4'
        WHEN M.MCKey = '76' THEN '4' 
        WHEN M.MCKey = '1' THEN '2' 
        WHEN M.MCKey = '4' THEN '4' 
        WHEN M.MCKey = '31' THEN '2' 
        WHEN M.MCKey = '6' THEN '3' 
        WHEN M.MCKey = '33' THEN '2' 
        WHEN M.MCKey = '66' THEN '4' 
        WHEN M.MCKey = '82' THEN '4' 
        WHEN M.MCKey = '32' THEN '2' 
        WHEN M.MCKey = '7' THEN '2' 
        WHEN M.MCKey = '101' THEN '4' 
        WHEN M.MCKey = '2' THEN '2' 
        WHEN M.MCKey = '15' THEN '2' 
        WHEN M.MCKey = '10' THEN '4' 
        WHEN M.MCKey = '78' THEN '3' 
        WHEN M.MCKey = '19' THEN '2' 
        ELSE '9' 
   END AS 'finance_support_code',
	patho.topo_code AS 'topo_code',
   patho.morpho AS 'morphology',
	IIF( patho.behavior_code IS NOT NULL , patho.behavior_code ,'3') AS 'behaviour_code',
	IIF( patho.grade_code IS NOT NULL , patho.grade_code ,'9') AS 'grade_code',
	-- patho.patho_approve_date,
	cv.stage_code AS 'stage_code',
	cv.t,
	cv.n,
   cv.m,
	cv.extension_code AS 'extension_code',
	-- IIF(cv.t IS NULL AND cv.n IS NULL AND cv.m IS NULL ,NULL , FORMAT(cv.DocDT, 'yyyyMMdd')) AS 'tnm_date',
	IIF(cv.recurrent = '1', 'Y', NULL) AS 'recurrent', 
   -- IIF(cv.recurrent = '1', FORMAT(cv.DocDT, 'yyyyMMdd'), NULL ) AS 'recurrent_date',  
   DATEADD(DAY, 0, GETDATE()) AS 'send_date' 
FROM dbo.Patient AS P 
 LEFT JOIN dbo.Person AS PER ON PER.PersonKey = P.PatientKey 
 LEFT JOIN dbo.Visit AS V ON V.PatientKey = P.PatientKey 
 LEFT JOIN dbo.Title T ON PER.TitleKey = T.TitleKey 
 LEFT JOIN cv ON cv.PatientKey = P.PatientKey
 INNER JOIN dbo.VisitMC VMC ON VMC.VisitMCKey = CV.MainVisitMCKey 
 INNER JOIN dbo.PatientMC PMC ON PMC.PatientMCKey = VMC.PatientMCKey 
 INNER JOIN dbo.MC M ON M.MCKey = PMC.MCKey 
 LEFT JOIN (SELECT DISTINCT cv.PatientKey ,FORMAT(MIN(cv.docdt), 'yyyyMMdd') 'first_cancer_visit',
 FORMAT(MAX(cv.docdt), 'yyyyMMdd') 'Last_cancer_visit'FROM dbo.ClinicVisit cv
 LEFT JOIN dbo.CNDX dx on dx.ClinicVisitKey = cv.ClinicVisitKey 
 	WHERE cv.ClinicVisitSKey <> 32 AND dx.Icd10Code LIKE 'C%' 
	GROUP BY cv.PatientKey) dx_date on dx_date.PatientKey = p.PatientKey
 LEFT JOIN patho ON patho.patientkey = p.PatientKey
	WHERE 
  	 CONVERT(VARCHAR, CV.DocDT, 103) = CONVERT(VARCHAR, DATEADD(DAY, -1, GETDATE()), 103) 
   -- CV.DocDT BETWEEN '2025-07-02' AND GETDATE()
    AND LEN(TRIM(PER.Cid)) = 13 
    AND CV.ClinicVisitKey IN ( SELECT DISTINCT dbo.ClinicVisit.ClinicVisitKey 
      FROM dbo.CNDX 
   		INNER JOIN dbo.ClinicVisit ON CNDX.ClinicVisitKey = ClinicVisit.ClinicVisitKey 
      WHERE 
        	CONVERT(VARCHAR, ClinicVisit.DocDT, 103) = CONVERT(VARCHAR, DATEADD(DAY, -1, GETDATE()), 103) 
         -- ClinicVisit.DocDT BETWEEN '2025-07-02' AND GETDATE()
         AND CNDX.DXTypeKey = '1' 
         AND UPPER(CNDX.Icd10Code) LIKE 'C%' )