-- Medical Data DataBase 
-- Piotr Czajka
-- Mateusz Mikłaszewicz
-- Krzysztof Spyra

DROP TABLE AstronautAfflictions CASCADE CONSTRAINTS;
DROP TABLE blood_analysis CASCADE CONSTRAINTS;
DROP TABLE Norms CASCADE CONSTRAINTS;
DROP TABLE lab_tests CASCADE CONSTRAINTS;
DROP TABLE doctors CASCADE CONSTRAINTS;
DROP TABLE Laboratories CASCADE CONSTRAINTS;
DROP TABLE Diagnoses CASCADE CONSTRAINTS;
DROP TABLE Measurements CASCADE CONSTRAINTS;
DROP TABLE Astronauts CASCADE CONSTRAINTS;
DROP TABLE Afflictions CASCADE CONSTRAINTS;
DROP VIEW results_summary;


CREATE TABLE Afflictions (
    affliction_id INTEGER PRIMARY KEY,
    name VARCHAR2(50) NOT NULL,
    type VARCHAR2(50) NOT NULL
);

-- ASTRONAUTS
CREATE TABLE Astronauts ( 
    astronaut_id INTEGER PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    gender VARCHAR(10) CHECK (gender IN ('M', 'F', 'Other')),
    blood_group VARCHAR(30) NOT NULL,
    date_of_birth DATE,
    height DECIMAL(5,2) CHECK (height > 140.00 AND height < 220.00),
    weight DECIMAL(5,2) CHECK (weight > 50.00 AND weight < 100.00)
);

CREATE TABLE Laboratories (
    laboratory_id INTEGER PRIMARY KEY,
    address VARCHAR2(50) NOT NULL
);

CREATE TABLE doctors(
	doctor_id INTEGER PRIMARY KEY,
	first_name VARCHAR2(30) NOT NULL,
    last_name VARCHAR2(30) NOT NULL,
	gender VARCHAR2(5) CHECK (gender in ('M', 'F', 'Other')),
	specialization VARCHAR2(30) NOT NULL,
    laboratory_id INTEGER,
	constraint fk_lab FOREIGN KEY (laboratory_id) REFERENCES laboratories(laboratory_id)
);


CREATE TABLE lab_tests(
	labtest_id INTEGER PRIMARY KEY,
	date_of_test DATE NOT NULL,
	description VARCHAR2(255),
	is_valid NUMBER(1) NOT NULL,
	type VARCHAR2(20) NOT NULL,
    astronaut_id INTEGER NOT NULL, 
    doctor_id INTEGER NOT NULL,    
    laboratory_id INTEGER NOT NULL,
	constraint astronaut_fk FOREIGN KEY (astronaut_id) REFERENCES astronauts(astronaut_id),
	constraint doctor_fk  FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
	constraint lab_fk FOREIGN KEY (laboratory_id) REFERENCES laboratories(laboratory_id)
);

CREATE TABLE Norms (
    parameter_code VARCHAR2(10) PRIMARY KEY,
    name VARCHAR2(50) NOT NULL,
    low NUMBER(6,2) NOT NULL,
    high NUMBER(6, 2) NOT NULL,
    unit VARCHAR2(20) NOT NULL
);


CREATE TABLE blood_analysis(
	blood_analysis_id INTEGER PRIMARY KEY,
    parameter_code VARCHAR2(10),
	b_value NUMBER(6,2) NOT NULL,
	result VARCHAR(1) CHECK (result in ('H', 'L', '~')),
    labtest_id INTEGER NOT NULL,
	constraint fk_labtest FOREIGN KEY (labtest_id) REFERENCES lab_tests(labtest_id),
	constraint fk_norms FOREIGN KEY (parameter_code) REFERENCES norms(parameter_code)
);

CREATE TABLE Diagnoses (
    diagnose_id INTEGER PRIMARY KEY,
    astronaut_id INTEGER,
    date_of_diagnose DATE,
    description VARCHAR2(255),
    CONSTRAINT fk_astronaut
        FOREIGN KEY (astronaut_id)
        REFERENCES Astronauts(astronaut_id)  
);


CREATE TABLE Measurements (
    measurement_id INTEGER PRIMARY KEY,
    astronaut_id INTEGER,
    body_temperature NUMBER(4,2),
    bpm NUMBER(3,0),
    date_of_measurement TIMESTAMP,
    diastolic_pressure NUMBER(3,0),
    saturation NUMBER(3,0),
    systolic_pressure NUMBER(3,0),
    CONSTRAINT fk_astronaut_meas 
        FOREIGN KEY (astronaut_id) 
        REFERENCES Astronauts(astronaut_id)
);

CREATE TABLE AstronautAfflictions (
    astronaut_id INTEGER,
    affliction_id INTEGER,
    PRIMARY KEY (astronaut_id, affliction_id),
    constraint aa_astronaut_fk FOREIGN KEY (astronaut_id) REFERENCES Astronauts(astronaut_id),
    constraint aa_affliction_fk FOREIGN KEY (affliction_id) REFERENCES Afflictions(affliction_id)
);




-- 1. TABELE GŁÓWNE I SŁOWNIKI

INSERT INTO Afflictions (affliction_id, name, type) VALUES (1, 'Space Motion Sickness', 'Neurological');
INSERT INTO Afflictions (affliction_id, name, type) VALUES (2, 'Bone Density Loss', 'Musculoskeletal');
INSERT INTO Afflictions (affliction_id, name, type) VALUES (3, 'Muscle Atrophy', 'Musculoskeletal');
INSERT INTO Afflictions (affliction_id, name, type) VALUES (4, 'Radiation Exposure', 'Oncological');

INSERT INTO Astronauts (astronaut_id, first_name, last_name, gender, blood_group, date_of_birth, height, weight) 
VALUES (1, 'Mark', 'Watney', 'M', 'O+', TO_DATE('1994-10-12', 'YYYY-MM-DD'), 185.50, 82.50);
INSERT INTO Astronauts (astronaut_id, first_name, last_name, gender, blood_group, date_of_birth, height, weight) 
VALUES (2, 'Ellen', 'Ripley', 'F', 'A-', TO_DATE('1992-01-07', 'YYYY-MM-DD'), 175.00, 65.20);
INSERT INTO Astronauts (astronaut_id, first_name, last_name, gender, blood_group, date_of_birth, height, weight) 
VALUES (3, 'Chris', 'Hadfield', 'M', 'AB+', TO_DATE('1959-08-29', 'YYYY-MM-DD'), 180.20, 78.00);

INSERT INTO Laboratories (laboratory_id, address) VALUES (1, 'ISS Destiny Module');
INSERT INTO Laboratories (laboratory_id, address) VALUES (2, 'Houston Space Center, TX');
INSERT INTO Laboratories (laboratory_id, address) VALUES (3, 'Cape Canaveral Bio-Lab, FL');

INSERT INTO Norms (parameter_code, name, low, high, unit) VALUES ('WBC', 'White Blood Cells', 4.50, 11.00, 'K/uL');
INSERT INTO Norms (parameter_code, name, low, high, unit) VALUES ('RBC', 'Red Blood Cells', 4.20, 5.80, 'M/uL');
INSERT INTO Norms (parameter_code, name, low, high, unit) VALUES ('HGB', 'Hemoglobin', 12.00, 17.50, 'g/dL');
INSERT INTO Norms (parameter_code, name, low, high, unit) VALUES ('CAL', 'Calcium', 8.50, 10.20, 'mg/dL');

-- 2. TABELE ZALEŻNE

INSERT INTO doctors (doctor_id, first_name, last_name, gender, specialization, laboratory_id) 
VALUES (1, 'Gregory', 'House', 'M', 'Diagnostician', 2);
INSERT INTO doctors (doctor_id, first_name, last_name, gender, specialization, laboratory_id) 
VALUES (2, 'Leonard', 'McCoy', 'M', 'Space Medicine', 1);
INSERT INTO doctors (doctor_id, first_name, last_name, gender, specialization, laboratory_id) 
VALUES (3, 'Beverly', 'Crusher', 'F', 'Biology', 3);

INSERT INTO Diagnoses (diagnose_id, astronaut_id, date_of_diagnose, description) 
VALUES (1, 1, TO_DATE('2023-11-01', 'YYYY-MM-DD'), 'Mild space motion sickness after docking.');
INSERT INTO Diagnoses (diagnose_id, astronaut_id, date_of_diagnose, description) 
VALUES (2, 2, TO_DATE('2023-11-15', 'YYYY-MM-DD'), 'Excellent health condition.');
INSERT INTO Diagnoses (diagnose_id, astronaut_id, date_of_diagnose, description) 
VALUES (3, 3, TO_DATE('2023-10-20', 'YYYY-MM-DD'), 'Early signs of calcium depletion in bones.'););

INSERT INTO AstronautAfflictions (astronaut_id, affliction_id) VALUES (1, 1);
INSERT INTO AstronautAfflictions (astronaut_id, affliction_id) VALUES (3, 2);
INSERT INTO AstronautAfflictions (astronaut_id, affliction_id) VALUES (3, 3);

-- 3. TESTY LABORATORYJNE I ICH WYNIKI

INSERT INTO lab_tests (labtest_id, date_of_test, description, is_valid, type, astronaut_id, doctor_id, laboratory_id) 
VALUES (1, TO_DATE('2023-11-02', 'YYYY-MM-DD'), 'Routine blood test post-launch', 1, 'BLOOD', 1, 2, 1);
INSERT INTO lab_tests (labtest_id, date_of_test, description, is_valid, type, astronaut_id, doctor_id, laboratory_id) 
VALUES (2, TO_DATE('2023-11-16', 'YYYY-MM-DD'), 'Standard checkup', 1, 'BLOOD', 2, 3, 3);
INSERT INTO lab_tests (labtest_id, date_of_test, description, is_valid, type, astronaut_id, doctor_id, laboratory_id) 
VALUES (3, TO_DATE('2023-10-21', 'YYYY-MM-DD'), 'Bone density related blood panel', 1, 'BLOOD', 3, 1, 2);
INSERT INTO lab_tests (labtest_id, date_of_test, description, is_valid, type, astronaut_id, doctor_id, laboratory_id) 
VALUES (4, TO_DATE('2023-10-22', 'YYYY-MM-DD'), 'Corrupted sample', 0, 'BLOOD', 3, 1, 2);

-- Tabela blood_analysis ma FK do lab_tests po ID
INSERT INTO blood_analysis (blood_analysis_id, parameter_code, b_value, result, labtest_id) VALUES (1, 'WBC', 5.20, '~', 1);
INSERT INTO blood_analysis (blood_analysis_id, parameter_code, b_value, result, labtest_id) VALUES (2, 'RBC', 4.50, '~', 1);
INSERT INTO blood_analysis (blood_analysis_id, parameter_code, b_value, result, labtest_id) VALUES (3, 'CAL', 7.90, 'L', 3);
INSERT INTO blood_analysis (blood_analysis_id, parameter_code, b_value, result, labtest_id) VALUES (4, 'HGB', 18.10, 'H', 2);

-- 4. MEASUREMENTS

-- Astronauta 1 (Mark Watney)
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (1, 1, 36.6, 72, TO_TIMESTAMP('2023-11-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 80, 99, 120);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (2, 1, 36.7, 75, TO_TIMESTAMP('2023-11-01 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 82, 98, 122);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (3, 1, 36.5, 70, TO_TIMESTAMP('2023-11-02 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 78, 99, 118);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (4, 1, 36.8, 80, TO_TIMESTAMP('2023-11-02 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 85, 97, 125);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (5, 1, 36.6, 73, TO_TIMESTAMP('2023-11-03 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 80, 99, 120);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (6, 1, 36.9, 85, TO_TIMESTAMP('2023-11-03 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 88, 96, 130);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (7, 1, 37.1, 90, TO_TIMESTAMP('2023-11-04 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 90, 95, 135);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (8, 1, 36.8, 82, TO_TIMESTAMP('2023-11-04 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 85, 98, 128);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (9, 1, 36.6, 74, TO_TIMESTAMP('2023-11-05 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 80, 99, 120);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (10, 1, 36.5, 71, TO_TIMESTAMP('2023-11-05 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 79, 99, 118);

-- Astronauta 2 (Ellen Ripley) - Stabilne pomiary
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (11, 2, 36.4, 60, TO_TIMESTAMP('2023-11-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 70, 100, 110);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (12, 2, 36.5, 62, TO_TIMESTAMP('2023-11-01 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 72, 99, 112);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (13, 2, 36.4, 61, TO_TIMESTAMP('2023-11-02 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 71, 100, 111);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (14, 2, 36.5, 63, TO_TIMESTAMP('2023-11-02 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 73, 99, 114);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (15, 2, 36.4, 60, TO_TIMESTAMP('2023-11-03 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 70, 100, 110);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (16, 2, 36.6, 64, TO_TIMESTAMP('2023-11-03 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 74, 99, 115);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (17, 2, 36.4, 61, TO_TIMESTAMP('2023-11-04 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 71, 100, 111);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (18, 2, 36.5, 62, TO_TIMESTAMP('2023-11-04 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 72, 99, 113);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (19, 2, 36.4, 60, TO_TIMESTAMP('2023-11-05 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 70, 100, 110);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (20, 2, 36.5, 61, TO_TIMESTAMP('2023-11-05 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 71, 100, 112);

-- Astronauta 3 (Chris Hadfield) - Lekkie skoki tętna i ciśnienia
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (21, 3, 36.6, 78, TO_TIMESTAMP('2023-11-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 85, 98, 130);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (22, 3, 36.7, 80, TO_TIMESTAMP('2023-11-01 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 88, 97, 135);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (23, 3, 36.6, 79, TO_TIMESTAMP('2023-11-02 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 86, 98, 132);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (24, 3, 36.8, 85, TO_TIMESTAMP('2023-11-02 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 90, 96, 140);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (25, 3, 36.6, 77, TO_TIMESTAMP('2023-11-03 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 85, 98, 130);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (26, 3, 36.7, 82, TO_TIMESTAMP('2023-11-03 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 88, 97, 136);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (27, 3, 36.6, 78, TO_TIMESTAMP('2023-11-04 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 85, 98, 131);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (28, 3, 36.9, 88, TO_TIMESTAMP('2023-11-04 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 92, 95, 145);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (29, 3, 36.6, 76, TO_TIMESTAMP('2023-11-05 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 84, 98, 128);
INSERT INTO Measurements (measurement_id, astronaut_id, body_temperature, bpm, date_of_measurement, diastolic_pressure, saturation, systolic_pressure) VALUES (30, 3, 36.7, 80, TO_TIMESTAMP('2023-11-05 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 87, 97, 133);

-- Indeksy na kluczach obcych (przyspieszenie laczenia)
CREATE INDEX idx_tests_astro ON lab_tests(astronaut_id);
CREATE INDEX idx_tests_doc ON lab_tests(doctor_id);
CREATE INDEX idx_meas_astro ON Measurements(astronaut_id);
CREATE INDEX idx_diag_astro ON Diagnoses(astronaut_id);


-- Indeksy na datach (jesli czesto bedzie szukane po dacie np. dane z ostatniego tygodnia)
CREATE INDEX idx_meas_date ON Measurements(date_of_measurement);
CREATE INDEX idx_tests_date ON lab_tests(date_of_test);


-- Indeksy na kolumnach tekstowych (wyszukiwanie po specjalizacji / nazwisku)
CREATE INDEX idx_doc_spec ON doctors(specialization);
CREATE INDEX idx_astro_name ON Astronauts(last_name, first_name);

-- Indeks unikatowy (kod parametru ma sie nie powtowrzyc)
CREATE UNIQUE INDEX idx_norm_name ON Norms(name);


CREATE OR REPLACE VIEW results_summary AS
SELECT a.first_name, a.last_name, n.name AS parameter, b.b_value, b.result, n.low, n.high, n.unit 
FROM Astronauts a 
JOIN lab_tests l ON (l.astronaut_id = a.astronaut_id) 
JOIN blood_analysis b ON (b.labtest_id = l.labtest_id) 
JOIN Norms n ON (b.parameter_code = n.parameter_code);

COMMIT;
