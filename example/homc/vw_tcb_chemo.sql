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
 from PATDIAG P2 
 where P2.Hn = P.Hn and ((ICDCode LIKE 'Z511') OR (ICDCode LIKE '9925') OR (ICDCode LIKE '9225') OR (ICDCode LIKE '9229'))
 order by P2.regNo desc) as visit_date 
 ,(select top 1  FORMAT(DATEADD(YEAR, -543, TRY_CONVERT(DATE, P2.VisitDate, 112)), 'yyyyMMdd')
 from PATDIAG P2 
 where P2.Hn = P.Hn and ((ICDCode LIKE 'Z511') OR (ICDCode LIKE '9925') OR (ICDCode LIKE '9225') OR (ICDCode LIKE '9229')) 
 order by P2.regNo desc) as treatment_start_date


 ,'2' AS treatment_code
 
  ,(select top 1 ICDCode from PATDIAG where Hn = P.Hn  and ((ICDCode LIKE 'Z511') OR (ICDCode LIKE '9925') OR (ICDCode LIKE '9225') OR (ICDCode LIKE '9229'))) as icd10_code

,DATEADD(DAY, 0, GETDATE()) AS send_date


 from PATDIAG P 
 INNER JOIN DEPT AS D (nolock) ON (P.deptCode = D.deptCode) 
 INNER JOIN PATIENT AS PP (nolock) ON (P.Hn = PP.hn)
  INNER JOIN Nation AS N (nolock) ON (PP.nation = N.NATCODE)
  INNER JOIN PatSS AS S (nolock) ON S.hn = P.Hn 
  RIGHT  join Bill_h   bh (nolock) on P.Hn = bh.hn and  bh.regNo  = (select top 1 P2.regNo 
 from PATDIAG P2 
 where P2.Hn = P.Hn and ((ICDCode LIKE 'Z511') OR (ICDCode LIKE '9925') OR (ICDCode LIKE '9225') OR (ICDCode LIKE '9229'))
 order by P2.regNo desc)
   left join Bill_d    b (nolock) on P.Hn=b.hn and P.regNo =b.regist_flag 

 where ((P.ICDCode LIKE 'Z511') OR (P.ICDCode LIKE '9925') OR (P.ICDCode LIKE '9225') OR (P.ICDCode LIKE '9229'))
 --and P.Hn = ''
--and P.DiagDate  between  '25680616' and '25680618' 
  --and P.DiagDate > '25680101' 

  and VisitDate = (CONVERT(varchar, DATEPART(YEAR, DATEADD(DAY, -1, GETDATE())) + 543) +
    RIGHT('0' + CONVERT(varchar, DATEPART(MONTH, DATEADD(DAY, -1, GETDATE()))), 2) +
    RIGHT('0' + CONVERT(varchar, DATEPART(DAY, DATEADD(DAY, -1, GETDATE()))), 2))