create table test(
	test1 integer
)

select user from dual;


SELECT * FROM astronauts;

SELECT * FROM measurements m JOIN astronauts a ON (m.astronaut_id = a.id) WHERE saturation < 96;

SELECT a.first_name, count(*) FROM lab_tests l JOIN astronauts a ON (l.astronaut_id = a.id) WHERE is_valid = 1 GROUP BY a.first_name;



SELECT first_name, n.name, b_value, result,  low,high, unit FROM astronauts a 
JOIN lab_tests l ON (l.astronaut_id = a.id) 
JOIN blood_analysis b ON (b.id = l.id) JOIN norms n ON 
(b.parameter_code = n.parameter_code);


CREATE VIEW results_summary AS
SELECT first_name, n.name, b_value, result,  low,high, unit FROM astronauts a 
JOIN lab_tests l ON (l.astronaut_id = a.id) 
JOIN blood_analysis b ON (b.id = l.id) JOIN norms n ON 
(b.parameter_code = n.parameter_code);


SELECT * FROM results_summary;