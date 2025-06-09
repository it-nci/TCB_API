SELECT DISTINCT
    p.hn,
    (CASE 
        WHEN CONVERT(p.pname USING utf8mb4) = 'นาย' THEN '1'
        WHEN CONVERT(p.pname USING utf8mb4) = 'นาง' THEN '2'
        WHEN CONVERT(p.pname USING utf8mb4) = 'น.ส.' THEN '3'
        WHEN CONVERT(p.pname USING utf8mb4) = 'ด.ช.' THEN '4'
        WHEN CONVERT(p.pname USING utf8mb4) = 'ด.ญ.' THEN '5'
        ELSE '6'
    END) AS title_code,
    TRIM(CONVERT(p.fname USING utf8mb4)) AS `name`,
    TRIM(CONVERT(p.lname USING utf8mb4)) AS last_name,
    DATE_FORMAT(p.birthday, "%Y%m%d") AS birth_date,
    CONCAT(
        SUBSTRING(CONVERT(p.cid USING utf8mb4), 1, 1), '-',
        SUBSTRING(CONVERT(p.cid USING utf8mb4), 2, 4), '-',
        SUBSTRING(CONVERT(p.cid USING utf8mb4), 6, 5), '-',
        SUBSTRING(CONVERT(p.cid USING utf8mb4), 11, 2), '-',
        SUBSTRING(CONVERT(p.cid USING utf8mb4), 13, 1)
    ) AS cid,
    p.sex AS sex_code,
    (CASE 
        WHEN p.nationality IS NULL OR p.nationality = '' THEN '9'
        WHEN CONVERT(p.nationality USING utf8mb4) = '99' THEN '1'
        WHEN CONVERT(p.nationality USING utf8mb4) = '44' THEN '2'
        WHEN CONVERT(p.nationality USING utf8mb4) = '56' THEN '3'
        WHEN CONVERT(p.nationality USING utf8mb4) = '57' THEN '4'
        WHEN CONVERT(p.nationality USING utf8mb4) = '48' THEN '5'
        ELSE '8'
    END) AS nationality_code,
    TRIM(CONCAT(
        CONVERT(p.addrpart USING utf8mb4), ' ',
        IF(p.road IS NULL, '', CONCAT('ถนน ', CONVERT(p.road USING utf8mb4))), ' ',
        IF(p.addr_soi IS NULL, '', CONCAT('ซอย ', CONVERT(p.addr_soi USING utf8mb4)))
    )) AS address_no,
    p.moopart AS address_moo,
    CONCAT(p.chwpart, p.amppart, p.tmbpart) AS area_code,
    TRIM(CONCAT(
        CONVERT(p.addrpart USING utf8mb4), ' ',
        IF(p.road IS NULL, '', CONCAT('ถนน ', CONVERT(p.road USING utf8mb4))), ' ',
        IF(p.addr_soi IS NULL, '', CONCAT('ซอย ', CONVERT(p.addr_soi USING utf8mb4)))
    )) AS permanent_address_no,
    p.moopart AS permanent_address_moo,
    CONCAT(p.chwpart, p.amppart, p.tmbpart) AS permanent_area_code,
    IF(p.hometel IS NULL OR p.hometel = '', p.informtel, p.hometel) AS telephone_1,
    DATE(CURDATE()) AS send_date
FROM patient p
LEFT OUTER JOIN ovst o ON p.hn = o.hn
WHERE 
    p.birthday IS NOT NULL
    AND o.vstdate = CURDATE()
    AND LENGTH(TRIM(CONVERT(p.cid USING utf8mb4))) = 13
    AND o.vn IN (
        SELECT DISTINCT od.vn
        FROM ovstdiag od
        WHERE od.vn = o.vn
          AND od.vstdate = CURDATE()
          AND od.diagtype = '1'
          AND UPPER(od.icd10) LIKE 'C%'
    );