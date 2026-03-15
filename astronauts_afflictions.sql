CREATE TABLE AstronautAfflictions (
    astronaut_id INTEGER,
    affliction_id INTEGER,
    PRIMARY KEY (astronaut_id, affliction_id),
    constraint astronaut_fk FOREIGN KEY (astronaut_id) REFERENCES Astronauts(id),
    constraint affliction_fk FOREIGN KEY (affliction_id) REFERENCES Affliction(id)
);