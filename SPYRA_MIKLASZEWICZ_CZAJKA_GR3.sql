-- Space Mission Medical Database 
-- GRUPA 3
-- Krzysztof Spyra
-- Mateusz Mikłaszewicz
-- Piotr Czajka


--Definicja package'u
CREATE OR REPLACE PACKAGE Astronaut_Health_Pkg AS

    --Funkcje
    FUNCTION count_abnormal_parameters (p_labtest_id IN INTEGER) RETURN INTEGER;
    FUNCTION average_measurements (id NUMBER, f TIMESTAMP, t TIMESTAMP) RETURN VARCHAR2;
    FUNCTION is_fit_for_eva (id NUMBER) RETURN VARCHAR2;
    FUNCTION get_health_alert (p_astronaut_id IN INTEGER) RETURN VARCHAR2;

    --Procedury
    PROCEDURE archive_measurements (p_months_old IN NUMBER DEFAULT 6);
    PROCEDURE calculate_bmi (id_ast IN NUMBER);

END Astronaut_Health_Pkg;
/


--TRIGGERY 

-- 1. Standaryzacja danych
-- Trigger służący do poprawy formatu wprowadzanych danych astronauty
-- Wywołuje się przed dodaniem nowego rekordu do tabeli astronauci
-- Przykład zmienia dane z ' adam   ', ' MiCkIeWicz' -> 'Adam', 'Mickiewicz'

CREATE OR REPLACE TRIGGER standarize_astronaut
BEFORE INSERT ON Astronauts
FOR EACH ROW
BEGIN

    -- Trim sluzacy do obciecia spacji przed oraz po danym argumencie
    -- Initcap sluzy do zapisania argumentu w formacie "pierwsza wielka litera" np. 'adam' -> 'Adam'
    :NEW.first_name := INITCAP(TRIM(:NEW.first_name));
    :NEW.last_name := INITCAP(TRIM(:NEW.last_name));
    :NEW.gender := UPPER(TRIM(:NEW.gender));

    -- Check czy wstawiany do tabeli astronauta ma poprawna date urodzenia
    -- nie moze urodzic sie jutro ani dzisiaj
    IF :NEW.date_of_birth >= SYSDATE THEN
        RAISE_APPLICATION_ERROR(102, 'Bledna data urodzenia astronauty');
    END IF;
END;
/

-- 2. Propagacja pomiędzy tabelami

--2.1)
-- Trigger słuzacy do update'owania istniejących rekordów na podstawie zaaktualizowanych norm
-- Przykładowo zmieniamy wartości graniczne dla magnezu z 4.0 - 5.0 na 5.0 - 6.0
-- Istniejące rekordy z wartosciami np 5.4 będą miały zaaktualizowany wynik (z 'H' na '~' [w normie])

CREATE OR REPLACE TRIGGER recalculate_norms
    --wywolanie triggera po wstawieniu nowej normy, lub aktualizacji pól high, low istniejących norm
    AFTER INSERT OR UPDATE OF low, high ON Norms
    FOR EACH ROW
BEGIN
    UPDATE blood_analysis
    SET result = CASE
                WHEN b_value < :NEW.low THEN 'L'
                WHEN b_value > :NEW.high THEN 'H'
                ELSE '~'
            END
    WHERE parameter_code = :NEW.parameter_code;
END;
/


--2.2)
-- Triger słuzacy do obliczania wyniku (H, L, ~) na podstawie tabeli z wartościami granicznymi dla poszczególnych badan
-- Przykładowo astronauta z ID: 1 ma badanie poziomu krwinek czerwonych
-- Jako ze nie znamy wyniku bezposrednio na podstawie danych z tabeli blood results, musimy odwołac sie do tabeli Norms
-- przed wstawieniem danych.
CREATE OR REPLACE TRIGGER calculate_norms
    BEFORE INSERT OR UPDATE OF b_value ON blood_analysis
    FOR EACH ROW
    DECLARE
        v_low Norms.low%TYPE;
        v_high Norms.high%TYPE;
BEGIN
    --check czy kod parametu i jego wartość wogole istnieją
    IF :NEW.parameter_code IS NOT NULL AND :NEW.b_value IS NOT NULL THEN
        BEGIN
            SELECT low, high
            INTO v_low, v_high
            FROM Norms
            WHERE parameter_code = :NEW.parameter_code;

            --odpowiednie przypisanie rezultatu
            IF :NEW.b_value < v_low THEN
                :NEW.result := 'L';
            ELSIF :NEW.b_value > v_high THEN
                :NEW.result := 'H';
            ELSE
                :NEW.result := '~';
            END IF;
        END;
    END IF;
END;
/

--3. Modyfikacja przez widok
-- Trigger sluzący do dodania lekarza bezposrednio przez widok neurologów
-- Uzywając widoku neurologów jestesmy w stanie dodać lekarza z odpowiednio przypisaną specjalizacją


-- Dodatkowo dodano sekwencje w celach pomocniczych
CREATE SEQUENCE seq_doctor_id START WITH 10 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER insert_doctor
INSTEAD OF INSERT ON neurologists
FOR EACH ROW
DECLARE
    v_doctor_id INTEGER;
    v_specialization_id INTEGER;
BEGIN
    BEGIN
        SELECT specialization_id INTO v_specialization_id
        FROM Specializations
        WHERE name = :NEW.name;
    END;

    v_doctor_id := seq_doctor_id.NEXTVAL;

    INSERT INTO Doctors (doctor_id, first_name, last_name)
    VALUES (v_doctor_id, :NEW.first_name, :NEW.last_name);

    -- "bindowanie" lekarza wraz ze specjalizacją (tabela asocjacyjna)
    INSERT INTO DoctorSpecializations (doctor_id, specialization_id)
    VALUES (v_doctor_id, v_specialization_id);
END;
/




CREATE OR REPLACE PACKAGE BODY Astronaut_Health_Pkg AS

    -- FUNKCJE

    -- 1. Funkcja slużąca do zliczenia ilości wyników nie mieszczących się w normach
    -- dla danego lab_test_id, moze ona słuzyc jako wyznacznik dla informacji który astronauta
    -- jest najbardziej zagrozony pod katem zdrowotnym w celu doboru skladu na misje.
    FUNCTION count_abnormal_parameters (
        p_labtest_id IN INTEGER
    ) RETURN INTEGER 
    IS
        v_abnormal_count INTEGER;
    BEGIN
        -- Liczy wszystkie wyniki które nie są oznaczone jako w normie ('~')
        SELECT COUNT(*)
        INTO v_abnormal_count
        FROM blood_analysis
        WHERE labtest_id = p_labtest_id
          AND result IN ('H', 'L');

        RETURN v_abnormal_count;
    END count_abnormal_parameters;

    -- 2. Funkcja sluzaca do obliczenia srednich wartosci funkcji zyciowych dla konkretnego astronauty
    -- Moze byc ona uzyta jako podsumowanie zdrowotne po powrocie z misji
    -- Udostepnia ona informacje o srednich z parametrow takicj jak saturacja krwii, cisnienie skurczowe i rozkurczowe
    -- oraz temperatura ciała oraz bpm w danym przedziale czasowym (timestamp'ie)
    FUNCTION average_measurements (id NUMBER, f TIMESTAMP, t TIMESTAMP) RETURN VARCHAR2 AS  --f -> from, t-> to
        ret VARCHAR2(255);
        tempAVG NUMBER := 0;
        bpmAVG NUMBER := 0;
        diPressureAVG NUMBER := 0;
        syPressureAVG NUMBER := 0;
        saturationAVG NUMBER := 0;
        r_count NUMBER := 0;

        -- Kursor zawiera dane wyłącznie o parametrach zyciowych danego astronauty (ID),
        -- w danym przedziale czasowym miedzy f (from) do t (to)
        CURSOR curr IS
            SELECT body_temperature, bpm, diastolic_pressure, saturation, systolic_pressure FROM 
            measurements WHERE astronaut_id = id AND date_of_measurement BETWEEN f AND t;
        vr_ast curr%ROWTYPE;
    BEGIN
        OPEN curr;
        
        LOOP
            FETCH curr INTO vr_ast;
            EXIT WHEN curr%NOTFOUND;
            
            tempAVG := tempAVG + vr_ast.body_temperature;
            bpmAVG := bpmAVG + vr_ast.bpm;
            diPressureAVG := diPressureAVG + vr_ast.diastolic_pressure;
            syPressureAVG := syPressureAVG + vr_ast.systolic_pressure;
            saturationAVG := saturationAVG + vr_ast.saturation;
            r_count := r_count + 1;
        END LOOP;
        CLOSE curr;

        IF r_count > 0 THEN
            ret := 'Srednie:  Temp:' || ROUND(tempAVG/r_count, 2) || ', BPM: ' || ROUND(bpmAVG/r_count, 2)
                || ', Cisnienie rozkurczowe: ' || ROUND(diPressureAVG/r_count, 2) || ', Cisnienie skurczowe: ' || ROUND(syPressureAVG/r_count, 2)
                || ', Saturacja: ' || ROUND(saturationAVG/r_count, 2);
        ELSE
            ret := 'Brak danych';
        END IF;

        RETURN ret;

    END average_measurements;

    -- 3. Funkcja pozwalająca na rozroznienie/identyfikacje czy astronauta o danym ID
    -- jest w stanie wyruszyc na "spacer kosmiczny", jako podstawe do dopuszczenia astronauty uzywane sa 
    -- jego parametry życiowe tj. bpm oraz saturacja
    FUNCTION is_fit_for_eva (id NUMBER) RETURN VARCHAR2 AS
        ret VARCHAR2(20);

        --Kursor zawiera wartosci na podstawie ktorych astronauta moze byc dopuszczony lub odrzucony
        -- do "spaceru kosmicznego" tj. bpm, saturacja (badamy 3 ostatnie rekordy)
        CURSOR curr IS
            SELECT bpm, saturation, date_of_measurement FROM measurements WHERE astronaut_id = id ORDER BY 
            date_of_measurement DESC FETCH FIRST 3 ROWS ONLY;
        vr_ast curr%ROWTYPE;

    BEGIN
        OPEN curr;
        
        ret := 'ZAAKCEPTOWANO';
        
        LOOP
            FETCH curr INTO vr_ast;
            EXIT WHEN curr%NOTFOUND;
            
            IF vr_ast.bpm > 85 THEN
                ret := 'ODRZUCONO';
            END IF;
            IF vr_ast.saturation < 98 THEN
                ret := 'ODRZUCONO';
            END IF;
        
        END LOOP;
        CLOSE curr;

        RETURN ret;
    END is_fit_for_eva;

    -- 4. Funkcja słuząca do zwrócenia alertów jesli astronauta o danym id przekroczy wartości graniczne
    -- parametrów życiowych tj. saturacja, bpm, cisnienie, temperatura
    FUNCTION get_health_alert (
        p_astronaut_id IN INTEGER
    ) RETURN VARCHAR2 
    IS
        v_temp NUMBER(4,2);
        v_bpm NUMBER(3,0);
        v_sat NUMBER(3,0);
        v_alert_msg VARCHAR2(255) := '';
    BEGIN
        -- Pobranie najnowszego pomiaru dla danego astronauty
        SELECT body_temperature, bpm, saturation
        INTO v_temp, v_bpm, v_sat
        FROM Measurements
        WHERE astronaut_id = p_astronaut_id
        ORDER BY date_of_measurement DESC
        FETCH FIRST 1 ROWS ONLY;

        -- Sprawdzanie odchyleń od normy (logika medyczna)
        IF v_sat < 96 THEN
            v_alert_msg := v_alert_msg || '[UWAGA: Niska saturacja: ' || v_sat || '%] ';
        END IF;
        
        IF v_bpm > 100 THEN
            v_alert_msg := v_alert_msg || '[UWAGA: Tachykardia: ' || v_bpm || ' bpm] ';
        END IF;
        
        IF v_temp > 37.5 THEN
            v_alert_msg := v_alert_msg || '[UWAGA: Stan podgorączkowy: ' || v_temp || '°C] ';
        END IF;

        RETURN v_alert_msg;
    END get_health_alert;

    -- PROCEDURY

    -- 1. Procedura sluzaca do archiwizacji danych historycznych (domyslnie pol roku w wstecz uwazane sa za dane aktualne)
    -- Po uplywie danego czasu dane sa przenoszone do nowo utworzonej tabeli sluzacej do archiwizacji zarówno samych rekordów (archive_measurements)
    -- jak i historycznych diagnoz (archive_diagnoses), po czym dane sa usuwane z tabeli aktualnych pomiarów (measurements)
    PROCEDURE archive_measurements (
        p_months_old IN NUMBER DEFAULT 6
    ) IS
        v_cutoff_date TIMESTAMP;
        v_archived_count INTEGER := 0;
        
        CURSOR c_summary (p_date TIMESTAMP) IS
            SELECT astronaut_id,
                   COUNT(*) as measurements_count,
                   ROUND(AVG(body_temperature), 2) as avg_temp,
                   ROUND(AVG(bpm), 2) as avg_bpm,
                   ROUND(AVG(systolic_pressure), 2) as avg_sys_press,
                   ROUND(AVG(diastolic_pressure), 2) as avg_dia_press,
                   ROUND(AVG(saturation), 2) as avg_sat
            FROM Measurements
            WHERE date_of_measurement < p_date
            GROUP BY astronaut_id;
    BEGIN
        -- Data graniczna, do której usuwamy dane
        --Obliczana za podstawie formuły: obecny timestamp (np 26.04.2026 15:07) - skonwertowana data do interwału w formie od roku do miesiaca np. 2025-05
        v_cutoff_date := SYSTIMESTAMP - NUMTOYMINTERVAL(p_months_old, 'MONTH');

        FOR v_rec IN c_summary(v_cutoff_date) LOOP

            --wstawianie historycznego podsumowania wraz ze srednimi
            INSERT INTO Archive_Diagnoses (
                diagnose_id, 
                astronaut_id, 
                date_of_diagnose, 
                description
            ) VALUES (
                seq_diagnose_id.NEXTVAL, 
                v_rec.astronaut_id, 
                SYSDATE, 
                -- Insertowanie podsumowania wraz ze srednimi wartoscami parametrów zyciowych z okreslonego przedzialu czasowego
                'PODSUMOWANIE PO ARCHIWIZACJI (>' || p_months_old || ' miesiecy): ' || 
                v_rec.measurements_count || ' pomiarów. ' ||
                'Sr Temp: ' || v_rec.avg_temp || 'C, Sr BPM: ' || v_rec.avg_bpm || 
                ', Sr Sys: ' || v_rec.avg_sys_press || v_rec.avg_dia_press ||  ', Sr Dia: ' ||
                ', Sr Sat' || v_rec.avg_sat || '.'
            );
        END LOOP;

        -- Wstawianie historycznych rekordów pomiarów
        INSERT INTO Measurements_Archive (
            archive_id, original_measurement_id, astronaut_id,
            body_temperature, bpm, date_of_measurement,
            diastolic_pressure, saturation, systolic_pressure
        )
        SELECT 
            seq_archive_id.NEXTVAL, measurement_id, astronaut_id,
            body_temperature, bpm, date_of_measurement,
            diastolic_pressure, saturation, systolic_pressure
        FROM Measurements
        WHERE date_of_measurement < v_cutoff_date;

        v_archived_count := SQL%ROWCOUNT;


        -- Usuniecie historycznych danych
        DELETE FROM Measurements
        WHERE date_of_measurement < v_cutoff_date;

        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Archiwizacja zakończona sukcesem.');
        DBMS_OUTPUT.PUT_LINE('Przeniesiono wierszy: ' || v_archived_count);

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Błąd podczas archiwizacji: ' || SQLERRM);
    END archive_measurements;


    -- 2. Procedura sluzaca do obliczania BMI danego astronauty identyfikowanego poprzez ID
    PROCEDURE calculate_bmi (id_ast IN NUMBER) AS
        wynik NUMBER;
        CURSOR curr IS
            SELECT height, weight FROM astronauts WHERE astronaut_id = id_ast;

        vr_ast curr%ROWTYPE;
        BEGIN
            OPEN curr;
            FETCH curr INTO vr_ast;
            
            --formuła bmi waga/(wzrost/100)^2
            DBMS_OUTPUT.PUT_LINE(vr_ast.weight/((vr_ast.height/100)*(vr_ast.height/100)));
            CLOSE curr;

        EXCEPTION
            WHEN cursor_already_open THEN
                IF(curr%ISOPEN) THEN
                   DBMS_OUTPUT.PUT_LINE('Kursor juz otwarty');
                CLOSE curr;
                END IF;
            WHEN OTHERS THEN
                CLOSE curr;
    END calculate_bmi;

END Astronaut_Health_Pkg;
/