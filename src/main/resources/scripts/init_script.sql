CREATE USER manager IDENTIFIED BY password
DEFAULT TABLESPACE users QUOTA UNLIMITED ON users
TEMPORARY TABLESPACE temp;

GRANT ALL PRIVILEGES TO manager;

CREATE TABLE manager.tb_users (
    id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY START WITH 7 INCREMENT BY 1,
    name VARCHAR2(250),
    date_of_birth DATE,
    email VARCHAR2(250),
    ssn VARCHAR2(12)
);

ALTER TABLE manager.tb_users ADD CONSTRAINT user_id_pk PRIMARY KEY (id); 
ALTER TABLE manager.tb_users ADD CONSTRAINT user_email_unique UNIQUE (email); 
ALTER TABLE manager.tb_users ADD CONSTRAINT user_ssn_unique UNIQUE (ssn);

INSERT INTO manager.tb_users (id, name, date_of_birth, email, ssn) 
VALUES (1, 'Lenna Dudney', TO_DATE('1995-08-22', 'YYYY-MM-DD'), 'ldudney1@paginegialle.it', '733-38-3444');

INSERT INTO manager.tb_users (id, name, date_of_birth, email, ssn) 
VALUES (2, 'Maryann Boumphrey', TO_DATE('1999-03-13', 'YYYY-MM-DD') , 'mboumphrey3@51.la', '279-37-6395');

INSERT INTO manager.tb_users (id, name, date_of_birth, email, ssn) 
VALUES (3, 'Gonzales Bewshaw', TO_DATE('1982-10-14', 'YYYY-MM-DD'), 'gbewshaw4@wordpress.org', '445-38-3202');

INSERT INTO manager.tb_users (id, name, date_of_birth, email, ssn) 
VALUES (4, 'Caz Colombier', TO_DATE('2001-01-25', 'YYYY-MM-DD'), 'ccolombier5@yelp.com', '388-32-8260');

INSERT INTO manager.tb_users (id, name, date_of_birth, email, ssn) 
VALUES (5, 'Rayna Geibel', TO_DATE('1986-02-04', 'YYYY-MM-DD'), 'rgeibel6@wikipedia.org', '403-08-3500');

INSERT INTO manager.tb_users (id, name, date_of_birth, email) 
VALUES (6, 'Rori Itzkovwitch', TO_DATE('1993-04-09', 'YYYY-MM-DD'), 'ritzkovwitch7@de.vu', '790-66-3434');

COMMIT;

CREATE OR REPLACE TYPE manager.t_user AS OBJECT (
    id               NUMBER,
    name             VARCHAR2(250),
    date_of_birth    DATE,
    email            VARCHAR2(250),
    ssn              VARCHAR2(12)
);

CREATE OR REPLACE TYPE manager.t_users IS TABLE OF manager.t_user;