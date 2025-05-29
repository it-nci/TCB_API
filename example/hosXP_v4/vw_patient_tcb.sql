SELECT DISTINCT
    p.hn,
    CASE 
        WHEN p.pname = 'นาย' THEN '1'
        WHEN p.pname = 'นาง' THEN '2'
        WHEN p.pname = 'น.ส.' THEN '3'
        WHEN p.pname = 'ด.ช.' THEN '4'
        WHEN p.pname = 'ด.ญ.' THEN '5'
        ELSE '6'
    END AS title_code,
    
    TRIM(p.fname) AS name,
    TRIM(p.lname) AS last_name,
    
    TO_CHAR(p.birthday, 'YYYYMMDD') AS birth_date,
    
    CONCAT(
        SUBSTRING(p.cid FROM 1 FOR 1), '-', 
        SUBSTRING(p.cid FROM 2 FOR 4), '-', 
        SUBSTRING(p.cid FROM 6 FOR 5), '-', 
        SUBSTRING(p.cid FROM 11 FOR 2), '-', 
        SUBSTRING(p.cid FROM 13 FOR 1)
    ) AS cid,
    
    p.sex AS sex_code,
    
    CASE 
        WHEN p.nationality IS NULL OR p.nationality = '' THEN '9'
        WHEN p.nationality = '99' THEN '1'
        WHEN p.nationality = '44' THEN '2'
        WHEN p.nationality = '56' THEN '3'
        WHEN p.nationality = '57' THEN '4'
        WHEN p.nationality = '48' THEN '5'
        ELSE '8'
    END AS nationality_code,
    
    TRIM(
        p.addrpart || ' ' ||
        COALESCE(NULLIF(p.road, ''), '') || 
        CASE WHEN p.road IS NOT NULL THEN ' ถนน ' || p.road ELSE '' END || ' ' ||
        CASE WHEN p.addr_soi IS NOT NULL THEN 'ซอย ' || p.addr_soi ELSE '' END
    ) AS address_no,
    
    p.moopart AS address_moo,
    
    CONCAT(p.chwpart, p.amppart, p.tmbpart) AS area_code,
    
    TRIM(
        p.addrpart || ' ' ||
        COALESCE(NULLIF(p.road, ''), '') || 
        CASE WHEN p.road IS NOT NULL THEN ' ถนน ' || p.road ELSE '' END || ' ' ||
        CASE WHEN p.addr_soi IS NOT NULL THEN 'ซอย ' || p.addr_soi ELSE '' END
    ) AS permanent_address_no,
    
    p.moopart AS permanent_address_moo,
    
    CONCAT(p.chwpart, p.amppart, p.tmbpart) AS permanent_area_code,
    
    CASE 
        WHEN p.hometel IS NULL OR p.hometel = '' THEN p.informtel 
        ELSE p.hometel 
    END AS telephone_1,
    
    CURRENT_DATE AS send_date

FROM patient p
LEFT JOIN ovst o ON p.hn = o.hn

WHERE 
    p.birthday IS NOT NULL
    AND o.vstdate = CURRENT_DATE
    AND LENGTH(TRIM(p.cid)) = 13
    AND o.vn IN (
        SELECT DISTINCT o.vn 
        FROM ovstdiag 
        WHERE o.vn = ovstdiag.vn 
          AND vstdate = CURRENT_DATE 
          AND diagtype = '1' 
          AND UPPER(icd10) LIKE 'C%'
    );
