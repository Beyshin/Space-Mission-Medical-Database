CREATE TABLE Diagnoses (
    id INTEGER PRIMARY KEY,
    astronaut_id INTEGER,
    date_of_diagnose DATE,
    description VARCHAR2(255),
    CONSTRAINT fk_astronaut
        FOREIGN KEY (astronaut_id)
        REFERENCES Astronauts(id)  
);