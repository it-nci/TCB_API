DROP VIEW vw_treatment_surgery_tcb;

CREATE VIEW vw_treatment_surgery_tcb AS
SELECT * 
FROM (
SELECT
	`o`.`hn` AS `hn`,
	concat(
		substr( `p`.`cid`, 1, 1 ),
		'-',
		substr( `p`.`cid`, 2, 4 ),
		'-',
		substr( `p`.`cid`, 6, 5 ),
		'-',
		substr( `p`.`cid`, 11, 2 ),
		'-',
	substr( `p`.`cid`, 13, 1 )) AS `cid`,
	date_format( `o`.`vstdate`, '%Y%m%d' ) AS `visit_date`,
	'1' AS `treatment_code`,
	date_format( `ol`.`request_date`, '%Y%m%d' ) AS `treatment_start_date`,
	`od`.`icd10` AS `icd10` 
FROM
	(((
				`ovst` `o`
				LEFT JOIN `ovstdiag` `od` ON ( `od`.`vn` = `o`.`vn` ))
			LEFT JOIN `operation_list` `ol` ON ( `ol`.`an` = `o`.`an` ))
	LEFT JOIN `patient` `p` ON ( `p`.`hn` = `o`.`hn` )) 
WHERE
	`o`.`vstdate` BETWEEN curdate() - INTERVAL 60 DAY 
	AND curdate() 
	AND `od`.`diagtype` = '1' 
	AND ucase( `od`.`icd10` ) LIKE 'C%' 
	AND `o`.`an` <> '' 
	AND `o`.`an` IS NOT NULL 
	AND `ol`.`status_id` = '3'
) DAT 
WHERE icd10 IS NOT NULL;