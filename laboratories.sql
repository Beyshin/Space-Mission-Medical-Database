CREATE TABLE lab_tests(
	id INTEGER PRIMARY KEY,
	date_of_test DATE NOT NULL,
	description VARCHAR2(255),
	is_valid BOOLEAN NOT NULL,
	type VARCHAR2(20) NOT NULl,
	astronaut_id INTEGER FOREIGN KEY REFERENCES astronauts(id),
	doctor_id INTEGER FOREIGN KEY REFERENCES doctors(id),
	lab_id INTEGER FOREIGN KEY REFERENCES laboratories(id)
)