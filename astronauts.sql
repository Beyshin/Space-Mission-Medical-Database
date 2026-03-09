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