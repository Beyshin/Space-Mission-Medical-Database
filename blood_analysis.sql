CREATE TABLE blood_analysis(
	id INTEGER PRIMARY KEY,
	value NUMBER(6,2) NOT NULL,
	result VARCHAR(1) CHECK (result in ('H', 'L', '~')),
	labtest_id INTEGER FOREIGN KEY REFERENCES lab_tests(id),
	parameter_code VARCHAR2(10) FOREIGN KEY REFERENCES norms(parameter_code)
)