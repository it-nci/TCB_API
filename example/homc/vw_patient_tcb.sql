
SELECT 
    DISTINCT 
CASE 
    -- �ó� CardID ��ҧ���� NULL
    WHEN ISNULL(LTRIM(RTRIM(S.CardID)), '') = '' THEN
        CASE 
            WHEN P.nation = '1' THEN '0-0000-00000-00-0'
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
            WHEN P.nation = '1' THEN '9-9999-99999-99-9'
            ELSE '0-0000-00000-00-0' 
        END
END AS cid

    ,P.hn AS hn, 
	CASE T.titleName  
    WHEN '���' THEN '1'
    WHEN '�ҧ' THEN '2'
    WHEN '�.�.' THEN '3'	
    WHEN '�.�.' THEN '4'
    WHEN '�.�.' THEN '5'
    WHEN '����ԡ��' THEN '6'
    ELSE '99'
	END AS title_code,
    ltrim(rtrim(P.firstName)) as name,
	ltrim(rtrim(P.lastName)) as last_name,       
	FORMAT(DATEADD(YEAR, -543, TRY_CONVERT(DATE, P.birthDay, 112)), 'yyyyMMdd') AS birth_date
    ,case   T.sex  
					when '�' then '1'
					when '�'then '2'
					when ''then 'F'			
					end as Sex_code,

	case   P.nation  
					when '99' then '1'
					when '20' then '2'
					when '56' then '3'
					when '30' then '4'
					when '48' then '5'
					when '97' then '8'
					when '00' then '9'
													
					end as nationality_code,
	--P.nation AS nationality_code,
		isnull(replace(addr1,'####',''),'')as address_no
	,isnull(replace(P.moo,'####',''),'')as address_moo
	,CAST(CONCAT(CAST(P.regionCode AS VARCHAR), CAST(P.tambonCode AS VARCHAR)) AS VARCHAR(6)) AS area_code   
	,isnull(replace(addr1,'####',''),'')as permanent_address_no
	,isnull(replace(P.moo,'####',''),'')as permanent_address_moo
	,CAST(CONCAT(CAST(P.regionCode AS VARCHAR), CAST(P.tambonCode AS VARCHAR)) AS VARCHAR(6)) AS permanent_area_code
	,'' as death_date,
	'' as daath_cause_code
	--,'' as passport
	,'' as email
	,ltrim(rtrim(CONVERT(nvarchar, mobilephone)))as telephone_1,
	DATEADD(DAY, 0, GETDATE()) AS send_date,
        
	(select top 1 ICDCode from DIAG where G.Hn = P.hn  and ICDCode like 'C%') as icd10
FROM 
    PATIENT P (nolock)
	INNER JOIN Nation AS N (nolock) ON (P.nation = N.NATCODE)
	INNER JOIN PTIT AS T (nolock) ON (P.titleCode = T.titleCode)
    INNER JOIN PaS AS S (nolock) ON (S.hn = P.hn)
    LEFT  JOIN AREA AS A (nolock) ON  (P.areaCode = A.areaCode)
	LEFT  JOIN REGION AS R (nolock) ON (P.regionCode = R.regionCode)
	LEFT  JOIN Tambon  (nolock) ON (Tambon.tambonCode = P.regionCode)
	LEFT  JOIN DIAG AS G (nolock) ON (P.hn = G.Hn)    
    LEFT  JOIN DEATH AS O (nolock)ON (P.hn = O.HN)
	LEFT JOIN OPD AS H (nolock) ON (H.hn = O.HN)
where 
G.ICDCode like 'C%'   
--and P.hn = ' '
--and G.DiagDate  between  '25680501' and '25680503' 
  and G.DiagDate = FORMAT(GETDATE(), 'yyyyMMdd', 'th-TH')