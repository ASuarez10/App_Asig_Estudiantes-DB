INSERT INTO HEADQUARTERS (HEADQUARTER_CITY, HEADQUARTER_ESTATE) VALUES ('Cali', 'Valle del Cauca');
INSERT INTO HEADQUARTERS (HEADQUARTER_CITY, HEADQUARTER_ESTATE) VALUES ('Palmira', 'Valle del Cauca');
INSERT INTO HEADQUARTERS (HEADQUARTER_CITY, HEADQUARTER_ESTATE) VALUES ('Bogota', 'Cundinamarca');
INSERT INTO HEADQUARTERS (HEADQUARTER_CITY, HEADQUARTER_ESTATE) VALUES ('Medellin', 'Antioquia');
INSERT INTO HEADQUARTERS (HEADQUARTER_CITY, HEADQUARTER_ESTATE) VALUES ('Barranquilla', 'Atlantico');
INSERT INTO HEADQUARTERS (HEADQUARTER_CITY, HEADQUARTER_ESTATE) VALUES ('Cartagena', 'Bolivar');

SELECT * FROM HEADQUARTERS;

INSERT INTO CAREERS (CAREER_NAME, FACULTY_NAME) VALUES ('Ingenieria de sistemas', 'Ingenieria');
INSERT INTO CAREERS (CAREER_NAME, FACULTY_NAME) VALUES ('Ingenieria industrial', 'Ingenieria');
INSERT INTO CAREERS (CAREER_NAME, FACULTY_NAME) VALUES ('Medicina', 'Ciencias de la salud');
INSERT INTO CAREERS (CAREER_NAME, FACULTY_NAME) VALUES ('Administracion de empresas', 'Ciencias administrativas');
INSERT INTO CAREERS (CAREER_NAME, FACULTY_NAME) VALUES ('Economia', 'Ciencias administrativas');

SELECT * FROM CAREERS;

INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (1, 1);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (1, 2);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (1, 3);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (1, 4);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (1, 5);

INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (2, 1);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (2, 2);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (2, 4);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (2, 5);

INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (3, 1);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (3, 2);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (3, 3);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (3, 4);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (3, 5);

INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (4, 1);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (4, 2);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (4, 3);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (4, 4);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (4, 5);

INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (5, 2);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (5, 4);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (5, 5);

INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (6, 1);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (6, 4);
INSERT INTO HEADQUARTERS_CAREERS (ID_HEADQUARTER, ID_CAREER) VALUES (6, 5);

SELECT * FROM HEADQUARTERS_CAREERS;

INSERT INTO EDUCATION_TYPES (EDUCATION_TYPE_NAME) VALUES ('Bachillerato');
INSERT INTO EDUCATION_TYPES (EDUCATION_TYPE_NAME) VALUES ('Tecnico');
INSERT INTO EDUCATION_TYPES (EDUCATION_TYPE_NAME) VALUES ('Tecnologo');

SELECT * FROM EDUCATION_TYPES;

INSERT INTO CRITERIA (ID_CRITERION, CATEGORY, NAME, COLUMN_NAME, TABLE_NAME, STATISTIC_TYPE, MANDATORY) 
VALUES ('1', 'Datos basicos', 'Sexo', 'SEX', 'CANDIDATES', 'Cualitative', '0');
INSERT INTO CRITERIA (ID_CRITERION, CATEGORY, NAME, COLUMN_NAME, TABLE_NAME, STATISTIC_TYPE, MANDATORY) 
VALUES ('2', 'Datos basicos', 'Ciudad de origen', 'CITY', 'CANDIDATES', 'Cualitative', '0');
INSERT INTO CRITERIA (ID_CRITERION, CATEGORY, NAME, COLUMN_NAME, TABLE_NAME, STATISTIC_TYPE, MANDATORY) 
VALUES ('3', 'Datos basicos', 'Departamento de origen', 'ESTATE', 'CANDIDATES', 'Cualitative', '0');
INSERT INTO CRITERIA (ID_CRITERION, CATEGORY, NAME, COLUMN_NAME, TABLE_NAME, STATISTIC_TYPE, MANDATORY) 
VALUES ('4', 'Datos basicos', 'Edad', 'AGE', 'CANDIDATES', 'Cuantitative', '0');
INSERT INTO CRITERIA (ID_CRITERION, CATEGORY, NAME, COLUMN_NAME, TABLE_NAME, STATISTIC_TYPE, MANDATORY) 
VALUES ('5', 'Educacion basica', 'Tipo de educacion', 'EDUCATION_TYPE_NAME', 'EDUCATION_TYPES', 'Cualitative', '0');
INSERT INTO CRITERIA (ID_CRITERION, CATEGORY, NAME, COLUMN_NAME, TABLE_NAME, STATISTIC_TYPE, MANDATORY) 
VALUES ('6', 'Prueba Saber', 'Puntaje general', 'ICFES_GENERAL', 'CANDIDATES', 'Cuantitative', '0');
INSERT INTO CRITERIA (ID_CRITERION, CATEGORY, NAME, COLUMN_NAME, TABLE_NAME, STATISTIC_TYPE, MANDATORY) 
VALUES ('7', 'Sede', 'Ciudad de interes', 'HEADQUARTER_CITY', 'HEADQUARTERS', 'Cualitative', '1');
INSERT INTO CRITERIA (ID_CRITERION, CATEGORY, NAME, COLUMN_NAME, TABLE_NAME, STATISTIC_TYPE, MANDATORY) 
VALUES ('8', 'Programa de interes', 'Nombre del programa de interes', 'CAREER_NAME', 'CAREERS', 'Cualitative', '1');

SELECT * FROM CRITERIA WHERE STATISTIC_TYPE = 'Cualitative';

UPDATE CRITERIA_CONFIGURATION 
SET VALUE  = '20' 
WHERE ID_CONF  = 47;

SELECT * FROM SELECTION_PROCESSES sp ;

DELETE FROM SELECTION_PROCESSES WHERE ID_PROCESS = 8;

SELECT * FROM CANDIDATES WHERE ID_CANDIDATE = '10000000000';

SELECT COUNT(ID_CANDIDATE) FROM CANDIDATES; 

SELECT * FROM CRITERIA_CONFIGURATION cc;

SELECT * FROM SELECTIONS s WHERE s.ID_SELECTION_PROCESS = 10;

--DELETE FROM SELECTIONS s ;

--DELETE FROM CRITERIA_CONFIGURATION;