WITH icd9 (ORRequestHeaderKey, PatientKey, or_date, AdmitKey, icd9cm) AS (
  SELECT
    o.ORRequestHeaderKey AS ORRequestHeaderKey,
    o.PatientKey AS PatientKey,
    FORMAT(o.ORStartDT, 'yyyyMMdd') AS or_date,
    o.AdmitKey AS AdmitKey,
    STRING_AGG(TRIM(REPLACE(itt.Icd9Code, '.', '')), ',') AS icd9cm
  FROM dbo.ORRequestHeader o
    LEFT JOIN dbo.ORRequest oo ON oo.ORRequestHeaderKey = o.ORRequestHeaderKey
    LEFT JOIN dbo.Item itt ON itt.ItemKey = oo.ItemKey
    LEFT JOIN dbo.Icd9 id ON id.Icd9Code = itt.Icd9Code
  WHERE
    itt.Icd9Code IS NOT NULL
    AND o.IsCanceled = 0
    AND o.AdmitKey IS NOT NULL
    AND TRIM(REPLACE(itt.Icd9Code, '.', '')) IN (
      '0034', '0062', '0064', '0124', '0131', '0139', '0151', '0153', '0159', '0251', '0252', '0253', '0303', '0309',
      '0403', '0415', '0436', '0437', '0500', '0503', '0504', '0526', '0527', '0540', '0543', '0544', '0576', '0613',
      '0623', '0631', '0639', '0643', '0664', '0688', '0689', '0713', '0721', '0722', '0729', '0780', '0784', '0822',
      '0825', '0835', '0850', '0863', '0864', '1214', '1264', '1473', '1659', '1732', '1733', '1734', '1735', '1736',
      '1739', '1829', '1831', '2041', '2169', '2231', '2239', '2241', '2242', '2252', '2260', '2262', '2263', '2264',
      '2594', '2630', '2631', '2632', '2732', '2742', '283', '2933', '3009', '3022', '3029', '3198', '3220', '3229',
      '3230', '3239', '3241', '3249', '3259', '3402', '343', '3451', '3481', '3491', '3492', '3731', '3816', '3845',
      '4021', '4022', '4023', '4024', '4029', '4040', '4041', '4042', '4050', '4051', '4052', '4053', '4054', '4059',
      '4143', '4210', '4211', '4233', '4240', '4241', '4242', '4254', '4319', '4342', '436', '437', '4381', '4389',
      '4391', '4399', '4502', '4503', '4533', '4541', '4542', '4543', '4551', '4552', '4561', '4562', '4563', '4572',
      '4573', '4574', '4575', '4576', '4579', '4581', '4582', '4583', '4590', '4591', '4592', '4593', '4594', '4601',
      '4602', '4603', '4610', '4639', '4701', '4709', '4719', '4849', '4850', '4851', '4852', '4862', '4863', '4869',
      '4874', '4939', '4946', '5022', '5023', '5024', '5025', '5026', '5029', '5103', '5121', '5122', '5123', '5124',
      '5132', '5136', '5149', '5151', '5162', '5169', '5185', '5222', '5251', '5252', '5253', '5296', '5421', '5423',
      '544', '5459', '5502', '554', '5551', '5640', '5641', '5642', '5661', '5675', '5749', '5759', '576', '5771',
      '5779', '5787', '5791', '5839', '6029', '604', '605', '6069', '6241', '6522', '6525', '6529', '6531', '6539',
      '6541', '6549', '6551', '6553', '6561', '6562', '6563', '6573', '6651', '6739', '6829', '683', '6839', '6841',
      '6849', '6851', '6859', '6861', '6869', '688', '7033', '713', '7161', '7162', '7631', '7639', '7641', '7642',
      '7661', '7671', '7675', '7676', '7720', '7721', '7727', '7751', '7762', '7765', '7767', '7769', '7773', '7779',
      '7781', '7789', '7791', '7817', '7853', '7855', '7857', '7859', '7901', '7902', '7904', '7905', '7911', '7912',
      '7914', '7915', '7916', '7931', '7932', '7934', '7935', '7936', '7937', '7938', '7939', '7972', '8051', '8086',
      '8087', '8099', '8151', '8152', '8203', '8339', '8345', '835', '8401', '8407', '8411', '8412', '8415', '8417',
      '843', '8521', '8522', '8523', '8531', '8541', '8542', '8543', '8544', '8545', '8572', '8573', '8622', '8628',
      '864', '9739', '9761'
    )
  GROUP BY
    o.ORRequestHeaderKey,
    o.PatientKey,
    o.AdmitKey,
    o.ORStartDT
)
SELECT DISTINCT
  CONCAT(
    SUBSTRING(PER.Cid, 1, 1), '-', 
    SUBSTRING(PER.Cid, 2, 4), '-', 
    SUBSTRING(PER.Cid, 6, 5), '-', 
    SUBSTRING(PER.Cid, 11, 2), '-', 
    SUBSTRING(PER.Cid, 13, 1)
  ) AS cid,
  FORMAT(admit.DocDT, 'yyyyMMdd') AS visit_date,
  UPPER(REPLACE(dx.Icd10Code, '.', '')) AS icd10_code,
  '1' AS treatment_code,
  icd9.or_date AS treatment_start_date,
  '' AS treatment_end_date,
  FORMAT(admit.DischargeDT, 'yyyyMMdd') AS dc_date,
  DATEADD(DAY, 0, GETDATE()) AS send_date
FROM icd9
  INNER JOIN dbo.Patient P ON icd9.PatientKey = P.PatientKey
  INNER JOIN dbo.Person PER ON PER.PersonKey = P.PatientKey
  INNER JOIN dbo.ANDX Dx ON icd9.AdmitKey = Dx.AdmitKey
  INNER JOIN dbo.Admit admit ON icd9.AdmitKey = admit.AdmitKey
WHERE
  CONVERT(VARCHAR, admit.DischargeDT, 103) = CONVERT(VARCHAR, GETDATE(), 103)
  AND LEN(TRIM(PER.Cid)) = 13
  AND dx.DXTypeKey = '1'
  AND UPPER(dx.Icd10Code) LIKE 'C%';
