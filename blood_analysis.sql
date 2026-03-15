CREATE TABLE blood_analysis(
	id INTEGER PRIMARY KEY,
    parameter_code VARCHAR2(10),
	b_value NUMBER(6,2) NOT NULL,
	result VARCHAR(1) CHECK (result in ('H', 'L', '~')),
	constraint fk_labtest FOREIGN KEY (id) REFERENCES lab_tests(id),
	constraint fk_norms FOREIGN KEY (parameter_code) REFERENCES norms(parameter_code)
);