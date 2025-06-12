
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
 ,(select top 1  FORMAT(DATEADD(YEAR, -543, TRY_CONVERT(DATE, P2.VisitDate, 112)), 'yyyyMMdd')
 from DIAG P2 
 where P2.Hn = P.Hn and ICDCode like 'C%' 
 order by P2.regNo desc) as treatment_start_date


 ,'3' AS treatment_code
 
  ,(select top 1 ICDCode from DIAG where Hn = P.Hn  and ICDCode like 'C%') as icd10_code

,DATEADD(DAY, 0, GETDATE()) AS send_date


 from DIAG P 
 INNER JOIN DEP AS D (nolock) ON (P.deptCode = D.deptCode) 
 INNER JOIN PATIENT AS PP (nolock) ON (P.Hn = PP.hn)
  INNER JOIN Nation AS N (nolock) ON (PP.nation = N.NATCODE)
  INNER JOIN PaS AS S (nolock) ON S.hn = P.Hn 
  RIGHT  join Bill   bh (nolock) on P.Hn = bh.hn and  bh.regNo  = (select top 1 P2.regNo 
 from DIAG P2 
 where P2.Hn = P.Hn and ICDCode like 'C%'
 order by P2.regNo desc)
   left join Bid    b (nolock) on P.Hn=b.hn and P.regNo =b.regist_flag 

 where ICDCode like 'C%' 
 --and P.Hn = ''
--and P.DiagDate  between  '25680503' and '25680505' 
  --and P.DiagDate > '25680101' 

  and VisitDate = FORMAT(GETDATE(), 'yyyyMMdd', 'th-TH')

 



