SELECT DISTINCT
    p.hn,
    (CASE 
            WHEN p.pname = 'นาย' THEN '1'
            WHEN p.pname = 'นาง' THEN '2'
            WHEN p.pname = 'น.ส.' THEN '3'
            WHEN p.pname = 'ด.ช.' THEN '4'
            WHEN p.pname = 'ด.ญ.' THEN '5'
            ELSE '6'
    END)  as title_code,
    TRIM(p.fname) AS `name`,
    TRIM(p.lname) AS last_name,
    DATE_FORMAT(p.birthday, "%Y%m%d") AS birth_date,
    CONCAT(SUBSTRING(p.cid, 1, 1), '-', SUBSTRING(p.cid, 2, 4), '-', SUBSTRING(p.cid, 6, 5), '-', SUBSTRING(p.cid, 11, 2), '-', SUBSTRING(p.cid, 13, 1)) AS cid,  
    p.sex AS sex_code,
    (CASE 
            WHEN p.nationality = '' OR p.nationality is null THEN '9'
            WHEN p.nationality = '99' THEN '1'
            WHEN p.nationality = '44' THEN '2'
            WHEN p.nationality = '56' THEN '3'
            WHEN p.nationality = '57' THEN '4'
            WHEN p.nationality = '48' THEN '5'
            ELSE '8'
    END)  as nationality_code,
    TRIM(CONCAT(p.addrpart, ' ', 
        IF(p.road IS NULL, '', CONCAT('ถนน ', p.road)), ' ', 
        IF(p.addr_soi IS NULL, '', CONCAT('ซอย ', p.addr_soi))
    )) AS address_no, 
    p.moopart AS address_moo,
    CONCAT(p.chwpart, p.amppart,p.tmbpart) AS area_code, 
    TRIM(CONCAT(p.addrpart, ' ', 
        IF(p.road IS NULL, '', CONCAT('ถนน ', p.road)), ' ', 
        IF(p.addr_soi IS NULL, '', CONCAT('ซอย ', p.addr_soi))
    )) AS permanent_address_no, 
    p.moopart AS permanent_address_moo, 
		CONCAT(p.chwpart, p.amppart,p.tmbpart) AS permanent_area_code,
    IF(p.mobile_phone_number = '' OR p.mobile_phone_number is null, p.informtel, p.mobile_phone_number) AS telephone_1,
    DATE(NOW()) AS send_date
FROM patient p
LEFT OUTER JOIN ovst o ON p.hn = o.hn
WHERE 
    p.birthday IS NOT NULL 
    AND o.vstdate = CURDATE()
-- 		AND o.vstdate = CURDATE() - INTERVAL 2 DAY
    AND length(TRIM(p.cid)) = 13
    AND o.vn IN (
        select distinct o.vn from ovstdiag 
				where o.vn = vn and vstdate = CURDATE()
-- 				where o.vn = vn and vstdate = CURDATE() - INTERVAL 2 DAY
				and diagtype = '1' and upper(icd10) like 'C%');
