SELECT
    o.hn AS hn,
    CONCAT(
        SUBSTRING(p.cid, 1, 1), '-',
        SUBSTRING(p.cid, 2, 4), '-',
        SUBSTRING(p.cid, 6, 5), '-',
        SUBSTRING(p.cid, 11, 2), '-',
        SUBSTRING(p.cid, 13, 1)
    ) AS cid,
    DATE_FORMAT(o.vstdate, '%Y%m%d') AS visit_date,
    '1' AS treatment_code,
    DATE_FORMAT(ol.request_date, '%Y%m%d') AS treatment_start_date,
    od.icd10 AS icd10
FROM
    ovst o
LEFT JOIN ovstdiag od ON od.vn = o.vn
LEFT JOIN operation_list ol ON ol.an = o.an
LEFT JOIN patient p ON p.hn = o.hn
WHERE
    o.vstdate = CURDATE()
    AND od.diagtype = '1'
    AND UPPER(od.icd10) LIKE 'C%'
    AND o.an IS NOT NULL
    AND o.an <> ''
    AND ol.status_id = '3'
    AND od.icd10 IS NOT NULL;