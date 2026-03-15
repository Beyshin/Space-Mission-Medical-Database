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