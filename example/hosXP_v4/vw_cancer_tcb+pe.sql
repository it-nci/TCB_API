 SELECT DISTINCT
        CASE
            WHEN pty.pcode = ANY (ARRAY['A1'::bpchar, 'A9'::bpchar, '94'::bpchar]) THEN '1'::text
            WHEN pty.pcode = ANY (ARRAY['B1'::bpchar, 'B2'::bpchar, 'B3'::bpchar, 'B4'::bpchar, 'B5'::bpchar, 'L1'::bpchar, 'L2'::bpchar, 'L3'::bpchar, 'L4'::bpchar, 'L5'::bpchar, 'L6'::bpchar, 'O1'::bpchar, 'O2'::bpchar, 'O3'::bpchar, 'O4'::bpchar, 'O5'::bpchar, 'UB'::bpchar, 'Z3'::bpchar]) THEN '2'::text
            WHEN pty.pcode = 'A7'::bpchar THEN '3'::text
            WHEN pty.pcode = ANY (ARRAY['A3'::bpchar, 'A5'::bpchar, 'AA'::bpchar, 'AB'::bpchar, 'AC'::bpchar, 'AD'::bpchar, 'AE'::bpchar, 'AF'::bpchar, 'AG'::bpchar, 'AH'::bpchar, 'AJ'::bpchar, 'AK'::bpchar, 'AL'::bpchar, 'UC'::bpchar]) THEN '4'::text
            ELSE '9'::text
        END AS finance_support_code,
    pcr.patient_cancer_last_visit_date AS clinic_visit,
    ((((((("substring"(p.cid::text, 1, 1) || '-'::text) || "substring"(p.cid::text, 2, 4)) || '-'::text) || "substring"(p.cid::text, 6, 5)) || '-'::text) || "substring"(p.cid::text, 11, 2)) || '-'::text) || "substring"(p.cid::text, 13, 1) AS cid,
    o.hn,
    to_char(o.vstdate::timestamp with time zone, 'YYYYMMDD'::text) AS visit_date,
    o.vstdate,
    ''::text AS diagnosis_code,
    ''::text AS morphology,
    '3'::text AS behaviour_code,
    pcr.cancer_grade_id AS grade,
    ''::text AS stage,
    pcr.t_value AS t,
    pcr.n_value AS n,
    pcr.m_value AS m,
    ''::text AS recurrent,
    ''::text AS recurrent_date,
    os.pe::text AS clinical_summary,
    ( SELECT upper(replace(od.icd10::text, '.'::text, ''::text)) AS upper
           FROM ovstdiag od
          WHERE od.vn::text = o.vn::text AND od.diagtype = '1'::bpchar AND upper(od.icd10::text) ~~ 'C%'::text
          ORDER BY od.diagtype
         LIMIT 1) AS icd10_code,
    to_char(CURRENT_DATE::timestamp with time zone, 'YYYYMMDD'::text) AS send_date
   FROM ovst o
     LEFT JOIN patient p ON p.hn::text = o.hn::text
     LEFT JOIN pttype pty ON pty.pttype = o.pttype
     LEFT JOIN patient_cancer_registeration pcr ON pcr.hn::text = o.hn::text
     LEFT JOIN opdscreen os on os.vn = o.vn
  WHERE o.vstdate = CURRENT_DATE AND length(btrim(p.cid::text)) = 13 AND (EXISTS ( SELECT 1
           FROM ovstdiag od
          WHERE od.vn::text = o.vn::text AND od.vstdate = CURRENT_DATE AND od.diagtype = '1'::bpchar AND upper(od.icd10::text) ~~ 'C%'::text))
  ORDER BY o.vstdate DESC
