CREATE TABLE lab_tests(
	id INTEGER PRIMARY KEY,
	date_of_test DATE NOT NULL,
	description VARCHAR2(255),
	is_valid BOOLEAN NOT NULL,
	type VARCHAR2(20) NOT NULL,
    astronaut_id INTEGER NOT NULL, 
    doctor_id INTEGER NOT NULL,    
    lab_id INTEGER NOT NULL,
	constraint astronaut_fk FOREIGN KEY (astronaut_id) REFERENCES astronauts(id),
	constraint doctor_fk  FOREIGN KEY (doctor_id) REFERENCES doctors(id),
	constraint lab_fk FOREIGN KEY (lab_id) REFERENCES laboratories(id)
);