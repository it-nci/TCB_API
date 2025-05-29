
select  Distinct 
--P.Hn,
CASE 
    -- �ó� CardID ��ҧ���� NULL
    WHEN ISNULL(LTRIM(RTRIM(S.CardID)), '') = '' THEN
        CASE 
            WHEN PP.nation = '1' THEN '0-0000-00000-00-0'
            ELSE '9-9999-99999-99-9' 
        END
    -- �ó� CardID ������� 13 ��Ǣ��� ���Ѵ�ٻẺ
    WHEN LEN(LTRIM(RTRIM(S.CardID))) >= 13 THEN
        SUBSTRING(LTRIM(RTRIM(S.CardID)), 1, 1) + '-' + 
        SUBSTRING(LTRIM(RTRIM(S.CardID)), 2, 4) + '-' + 
        SUBSTRING(LTRIM(RTRIM(S.CardID)), 6, 5) + '-' + 
        SUBSTRING(LTRIM(RTRIM(S.CardID)), 11, 2) + '-' + 
        SUBSTRING(LTRIM(RTRIM(S.CardID)), 13, 1)
    -- �ó���� � �� CardID �դ�ҹ��¡��� 13 ��ѡ
    ELSE 
        CASE 
            WHEN PP.nation = '1' THEN '9-9999-99999-99-9'
            ELSE '0-0000-00000-00-0' 
        END
END AS cid, 
D.deptDesc AS clinic_visit,
 (select top 1  FORMAT(DATEADD(YEAR, -543, TRY_CONVERT(DATE, P2.VisitDate, 112)), 'yyyyMMdd')
 from DIAG P2 
 where P2.Hn = P.Hn and ICDCode like 'C%' 
 order by P2.regNo desc) as visit_date
,NULL AS diagnosis_code
, ''as morphology
, '3'as behaviour_code
, ''as grade
, ''as grade_code
, '9'AS stage
, ''as stage_code 
,''as topo_code
,''as extension_code
,''as t, ''as n, ''as m
,''as tnm_date
,''as  recurrent
,'' as recurrent_date
,DATEADD(DAY, 0, GETDATE()) AS send_date
,case  bh.useDrg 
     when 'A1' then '1' 
     when 'A@' then '1' 
     when 'A2' then '1'
     when 'AX' then '1'
     when 'AY'then '2'
     when 'AU'then '2'
     when '04'then '2'
     when '05'then '2'
     when 'A7'then '3' 
     when '71'then '3'
     when '73'then '3'
     when '72'then '3'
     when '76'then '3'
     when '70'then '3'
     when 'UC'then '4'
     when '01'then '4'
     when 'UQ'then '4'
     when 'AF'then '4'
     when 'U1'then '4'
     when 'U2'then '4' 
     when 'U3'then '4'
     when 'U4'then '4'
     when 'EM'then '4' 
     when 'AD'then '4' 
     when 'UM'then '4' 
     when '77'then '4' 
     when 'B8'then '4' 
     when 'AB'then '9'
     when 'AS'then '9'
     when 'UH'then '9'
     when 'AG'then '9' 
     when '50'then '9' 
     when '51'then '9'
     when 'AE'then '9'
     when 'AT'then '9'
     when 'AA'then '9'
     when 'AJ'then '9'
     when 'AZ'then '9'
     when 'A-'then '9'
     when 'UK'then '9'
     when 'CT'then '9'
     when 'AA'then '9'
     when 'AL'then '9'
     when '09'then '9'
     when 'L5'then '9'
     when 'L1'then '9'
     when 'UO'then '9'
     when '79'then '9'
     when 'EA'then '9'  
	 ELSE '9'     
     end as finance_support_code 
,''as clinical_summary
,(select top 1 ICDCode from DIAG where Hn = P.Hn  and ICDCode like 'C%') as icd10_code
 from DIAG P 
 INNER JOIN DEP AS D (nolock) ON (P.deptCode = D.deptCode) 
 INNER JOIN PATIENT AS PP (nolock) ON (P.Hn = PP.hn)
  INNER JOIN Nation AS N (nolock) ON (PP.nation = N.NATCODE)
  INNER JOIN PatS AS S (nolock) ON S.hn = P.Hn 
  RIGHT  join Bil   bh (nolock) on P.Hn = bh.hn and  bh.regNo  = (select top 1 P2.regNo 
 from DIAG P2 
 where P2.Hn = P.Hn and ICDCode like 'C%'
 order by P2.regNo desc)
   left join Bil_d    b (nolock) on P.Hn=b.hn and P.regNo =b.regist_flag 
 where ICDCode like 'C%' 
 --and P.Hn = ' xxxxx'
--and P.DiagDate  between  '25680503' and '25680505' 
  and P.DiagDate = GETDATE()
