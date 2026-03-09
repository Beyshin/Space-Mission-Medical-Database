CREATE TABLE Norms (
    parameter_code VARCHAR2(10) PRIMARY KEY,
    name VARCHAR2(50) NOT NULL,
    low NUMBER(6,2) NOT NULL,
    high NUMBER(6, 2) NOT NULL,
    unit VARCHAR2(20) NOT NULL
);