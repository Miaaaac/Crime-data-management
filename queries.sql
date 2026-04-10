SELECT 
    ca.act_type,
    ROUND(AVG(cf.trial_end_date - ca.date_of_act), 2) AS avg_days_to_verdict,
    ROUND(AVG(cf.trial_end_date - ca.date_of_act) / 30.5, 1) AS avg_months_to_verdict,
    COUNT(DISTINCT cf.case_id) AS total_cases
FROM 
    crime_act ca
JOIN 
    case_file cf ON ca.case_id = cf.case_id
WHERE 
    cf.trial_end_date IS NOT NULL 
    AND ca.date_of_act IS NOT NULL
    AND cf.trial_end_date >= ca.date_of_act
GROUP BY 
    ca.act_type
ORDER BY 
    avg_days_to_verdict DESC;



SELECT 
    sh.name AS region_name,
    AVG(psh.income_level) AS avg_income,
    AVG(s.total_duration_months) AS avg_sentence_length
FROM spatial_hierarchy sh
JOIN case_location cl ON sh.location_id = cl.location_id
JOIN case_file cf ON cl.case_id = cf.case_id
JOIN sentence s ON cf.case_id = s.case_id
JOIN case_participant cp ON cf.case_id = cp.case_id
JOIN person_status_history psh ON cp.person_id = psh.person_id
WHERE sh.type = 'region'
GROUP BY sh.name
ORDER BY avg_income DESC;


SELECT r.year, r.region_id, r.clearance_rate, pd.officers_assigned
FROM region_statistics r
JOIN police_deployment pd
ON r.region_id = pd.region_id 
AND  r.year = pd.year
ORDER BY  r.year, r.region_id;


SELECT 
    c.name AS court_name, 
    ROUND(AVG(judge_load.cases_count)::numeric, 2) AS avg_ongoing_load
FROM (
    SELECT  
        j.court_id, 
        j.judge_id, 
        COUNT(cf.case_id) AS cases_count
    FROM judge j
    LEFT JOIN case_file cf ON j.court_id = cf.court_id
    JOIN case_status cs ON cf.case_status_id = cs.case_status_id
    WHERE cf.trial_end_date IS NULL 
      AND cs.name IN ('Open')
    GROUP BY j.court_id, j.judge_id
) AS judge_load
JOIN court c ON judge_load.court_id = c.court_id
GROUP BY c.name
ORDER BY avg_ongoing_load DESC;

