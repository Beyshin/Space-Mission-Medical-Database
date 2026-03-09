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