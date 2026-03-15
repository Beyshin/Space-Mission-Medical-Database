DROP TABLE AstronautAfflictions CASCADE CONSTRAINTS;
DROP TABLE blood_analysis CASCADE CONSTRAINTS;
DROP TABLE Norms CASCADE CONSTRAINTS;
DROP TABLE lab_tests CASCADE CONSTRAINTS;
DROP TABLE doctors CASCADE CONSTRAINTS;
DROP TABLE Laboratories CASCADE CONSTRAINTS;
DROP TABLE Diagnoses CASCADE CONSTRAINTS;
DROP TABLE Measurements CASCADE CONSTRAINTS;
DROP TABLE Astronauts CASCADE CONSTRAINTS;
DROP TABLE Affliction CASCADE CONSTRAINTS;

CREATE TABLE Affliction (
    id INTEGER PRIMARY KEY,
    name VARCHAR2(50) NOT NULL,
    type VARCHAR2(50) NOT NULL
);

-- ASTRONAUTS
CREATE TABLE Astronauts ( 
    id INTEGER PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    gender VARCHAR(10) CHECK (gender IN ('M', 'F', 'Other')),
    blood_group VARCHAR(30) NOT NULL,
    date_of_birth DATE,
    height DECIMAL(5,2) CHECK (height > 140.00 AND height < 220.00)
);

CREATE TABLE Laboratories (
    id INTEGER PRIMARY KEY,
    address VARCHAR2(50) NOT NULL
);

CREATE TABLE doctors(
	id INTEGER PRIMARY KEY,
	first_name VARCHAR2(30) NOT NULL,
	gender VARCHAR2(5) CHECK (gender in ('M', 'F', 'Other')),
	specialization VARCHAR2(30) NOT NULL,
    lab_id INTEGER,
	constraint fk_lab FOREIGN KEY (lab_id) REFERENCES laboratories(id)
);


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

CREATE TABLE Norms (
    parameter_code VARCHAR2(10) PRIMARY KEY,
    name VARCHAR2(50) NOT NULL,
    low NUMBER(6,2) NOT NULL,
    high NUMBER(6, 2) NOT NULL,
    unit VARCHAR2(20) NOT NULL
);


CREATE TABLE blood_analysis(
	id INTEGER PRIMARY KEY,
    parameter_code VARCHAR2(10),
	b_value NUMBER(6,2) NOT NULL,
	result VARCHAR(1) CHECK (result in ('H', 'L', '~')),
	constraint fk_labtest FOREIGN KEY (id) REFERENCES lab_tests(id),
	constraint fk_norms FOREIGN KEY (parameter_code) REFERENCES norms(parameter_code)
);

CREATE TABLE Diagnoses (
    id INTEGER PRIMARY KEY,
    astronaut_id INTEGER,
    date_of_diagnose DATE,
    description VARCHAR2(255),
    CONSTRAINT fk_astronaut
        FOREIGN KEY (astronaut_id)
        REFERENCES Astronauts(id)  
);


CREATE TABLE Measurements (
    id INTEGER PRIMARY KEY,
    astronaut_id INTEGER,
    body_temperature NUMBER(4,2),
    bpm NUMBER(3,0),
    date_of_measurement TIMESTAMP,
    diastolic_pressure NUMBER(3,0),
    saturation NUMBER(4,2),
    systolic_pressure NUMBER(3,0),
    CONSTRAINT fk_astronaut_meas 
        FOREIGN KEY (astronaut_id) 
        REFERENCES Astronauts(id)
);

CREATE TABLE AstronautAfflictions (
    astronaut_id INTEGER,
    affliction_id INTEGER,
    PRIMARY KEY (astronaut_id, affliction_id),
    constraint aa_astronaut_fk FOREIGN KEY (astronaut_id) REFERENCES Astronauts(id),
    constraint aa_affliction_fk FOREIGN KEY (affliction_id) REFERENCES Affliction(id)
);