CREATE TABLE doctors(
	id INTEGER PRIMARY KEY,
	first_name VARCHAR2(30) NOT NULL,
	gender VARCHAR2(5) CHECK (gender in ('M', 'F', 'Other')),
	specialization VARCHAR2(30) NOT NULL,
    lab_id INTEGER,
	constraint fk_lab FOREIGN KEY (lab_id) REFERENCES laboratories(id)
)
