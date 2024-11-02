-- -----------------------------------------------------------
--         LIMPIEZA DE DATOS 
-- -----------------------------------------------------------

create database if not exists clean; 

use clean; 

select * from limpieza limit 10;

DELIMITER //
CREATE PROCEDURE limp() 
BEGIN
    SELECT * FROM limpieza;
END //
DELIMITER ;

CALL LIMP();

-- RENOMBRAR COLUMNAS

ALTER TABLE LIMPIEZA CHANGE column `ï»¿Id?empleado` ID_EMPLEADO VARCHAR(20) NULL;
ALTER TABLE LIMPIEZA CHANGE column `gÃ©nero` GENDER VARCHAR(20) NULL;

-- VALORE DUPLICADOS 

SELECT 
    ID_EMPLEADO, COUNT(*) AS CANTIDAD_DUPLICADOS
FROM
    LIMPIEZA
GROUP BY ID_EMPLEADO
HAVING COUNT(*) > 1;

-- CONTAR VALORES DUPLICADOS 

SELECT 
    COUNT(*) AS CANTIDAD_DUPLICADOS
FROM
    (SELECT 
        ID_EMPLEADO, COUNT(*) AS CANTIDAD_DUPLICADOS
    FROM
        LIMPIEZA
    GROUP BY ID_EMPLEADO
    HAVING COUNT(*) > 1) SUBQUERY; 

-- ELIMINAR DUPLICADOS 

-- RENOMBRAR TABLE 

RENAME TABLE LIMPIEZA TO CONDUPLICADOS;

-- TABLA TEMPORAL 

CREATE TEMPORARY TABLE TEMP_LIMPIEZA AS 
SELECT distinct * FROM CONDUPLICADOS;

SELECT 
    COUNT(*) AS ORIGINAL
FROM
    CONDUPLICADOS;
SELECT 
    COUNT(*) AS ORIGINAL
FROM
    TEMP_LIMPIEZA;

-- CONVERTIR TABLA TEMPORAL A PERMANENTE (ELIMINA LOS DUPLICADOS)

CREATE TABLE LIMPIEZA AS SELECT * FROM
    TEMP_LIMPIEZA;

CALL LIMP();

DROP TABLE CONDUPLICADOS;

-- DESACTIVAR MODO SEGURO PARA HACER MODIFICACIONES 

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE LIMPIEZA CHANGE COLUMN `Apellido` LAST_NAME VARCHAR(50) NULL;
ALTER TABLE LIMPIEZA CHANGE COLUMN `star_date` START_DATE VARCHAR(50) NULL;


-- VER TIPOS DE DATOS 

describe LIMPIEZA;

CALL LIMP();

-- REMOVER ESPACIOS EXTRAS (1.IDIENTIFICAR - 2 ACTUALIZAR TABLA) 

SELECT NAME FROM LIMPIEZA 
WHERE LENGTH(NAME) - LENGTH(TRIM(NAME)) > 0;

-- (TRIM: ELIMINA ESPACIOS)
-- (ESTO DE ABAJO ES PARA PRIMERO ENSALLAR )

SELECT NAME, TRIM(LAST_NAME) AS LAST_NAME 
FROM LIMPIEZA
WHERE LENGTH(LAST_NAME) - LENGTH(TRIM(LAST_NAME)) > 0;

-- YA MODIFICADOS LOS ESPACIOS DE ANTES Y DESPUES DE LA PALABRA
UPDATE LIMPIEZA SET NAME = TRIM(NAME)
WHERE LENGTH(NAME) - LENGTH(TRIM(NAME)) > 0;

UPDATE LIMPIEZA SET NAME = TRIM(LAST_NAME)
WHERE LENGTH(LAST_NAME) - LENGTH(TRIM(LAST_NAME)) > 0;

-- REMOVER ESPACIOS ENTRE DOS PALABRAS (SE HACE EL EJEMPLO)
UPDATE LIMPIEZA SET area = REPLACE(area, ' ', '      ');

-- idientificar y eliminar los espacios 
-- SE IDIENTIFICAN LOS ESPACIOS CON (regexp '\\S{2,}') 

SELECT area FROM LIMPIEZA	
WHERE area regexp '\\S{2,}';

-- ELIMINAR LOS ESPACIOS 

SELECT area, TRIM(regexp_replace(area, '\\s+',' ')) as ensayo from limpieza; -- ensayo
UPDATE LIMPIEZA SET area = TRIM(regexp_replace(area, '\\s+',' ')); -- como es 

-- BUSCAR Y REEMPLAZAR (1.ENSAYAR 2. ACTUALIZAR TABLA 3.MODIFICAR PROPIEDAD (SI ES NECESARIO))

SELECT GENDER, -- PRUEBA
	CASE 	
		WHEN GENDER = 'HOMBRE' THEN 'MALE'
		WHEN GENDER = 'MUJER' THEN 'FEMALE'
		ELSE 'OTHER'
END AS GENDER1
FROM LIMPIEZA;

UPDATE LIMPIEZA SET GENDER = -- YA EN TABLAS 
	CASE 	
		WHEN GENDER = 'HOMBRE' THEN 'MALE'
		WHEN GENDER = 'MUJER' THEN 'FEMALE'
		ELSE 'OTHER'
	END;

-- MODIFICAR LA TABLA (COLUMNA TYPE)

describe LIMPIEZA;

ALTER TABLE LIMPIEZA modify COLUMN type TEXT;

-- EXAMPLE 

SELECT type, 
	CASE
		WHEN type = 1 then 'REMOTE'
		WHEN type = 0 then 'HYBRID'
        ELSE 'OTHER'
	END AS EJEMPLO
    FROM LIMPIEZA;

-- YA EN TABLAS

UPDATE LIMPIEZA SET type =
	CASE
		WHEN type = 1 THEN 'REMOTE'
		WHEN type = 0 THEN 'HYBRID'
        ELSE 'OTHER'
	END;
    
describe LIMPIEZA;

-- DAR FORMATO DE NUMERO A UN TEXTO

SELECT salary, 
			CAST(TRIM(replace(replace(salary, '$', ''), ',','')) AS DECIMAL (15,2)) FROM LIMPIEZA; -- (PRUEBA)

UPDATE LIMPIEZA SET salary = CAST(TRIM(replace(replace(salary, '$', ''), ',','')) AS DECIMAL (15,2));

-- MODIFICAR LA COLUMNA QUE NO SEA TIPO TEX SI NO INT

ALTER TABLE limpieza modify column salary int null;

DESCRIBE LIMPIEZA;


-- AJUSTAR FROMATO DE FECHAS 
-- COMODINES: '%/%' BUSCAN PATRONES DE TEXTO


SELECT birth_date FROM LIMPIEZA;

SELECT birth_date, CASE
	WHEN birth_date LIKE '%/%' THEN date_format(str_to_date(birth_date, '%m/%d/%y'), '%Y-%m-%d')
	WHEN birth_date LIKE '%/%' THEN date_format(str_to_date(birth_date, '%m/%d/%y'), '%Y-%m-%d')
ELSE null
END AS NEW_birth_date
FROM LIMPIEZA;

update LIMPIEZA set birth_date = CASE
	WHEN birth_date LIKE '%/%' THEN date_format(str_to_date(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
	WHEN birth_date LIKE '%/%' THEN date_format(str_to_date(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
ELSE null
END;

CALL LIMP();

ALTER TABLE LIMPIEZA MODIFY COLUMN birth_date date;
describe LIMPIEZA;


-- MODIFICANDO START_DATE

SELECT START_DATE FROM LIMPIEZA;

SELECT START_DATE, CASE                                                                             -- PRUEBA 
	WHEN START_DATE LIKE '%/%' THEN date_format(str_to_date(START_DATE, '%m/%d/%y'), '%Y-%m-%d')
	WHEN START_DATE LIKE '%/%' THEN date_format(str_to_date(START_DATE, '%m/%d/%y'), '%Y-%m-%d')
ELSE null
END AS NEW_START_DATE
FROM LIMPIEZA;

UPDATE LIMPIEZA SET START_DATE = CASE 
	WHEN START_DATE LIKE '%/%' THEN date_format(str_to_date(START_DATE, '%m/%d/%Y'), '%Y-%m-%d')
	WHEN START_DATE LIKE '%/%' THEN date_format(str_to_date(START_DATE, '%m/%d/%Y'), '%Y-%m-%d')
ELSE null
END;

ALTER TABLE LIMPIEZA MODIFY COLUMN START_DATE date;
describe LIMPIEZA;

-- EXPLORAR OTRAS FUNCIONES DE FECHA Y HORA

SELECT finish_date FROM LIMPIEZA;
CALL LIMP();


-- # "ensayos" hacer consultas de como quedarían los datos si queremos ensayar diversos cambios.
SELECT finish_date, str_to_date(finish_date, '%Y-%m-%d %H:%i:%s') AS fecha FROM LIMPIEZA;  -- convierte el valor en objeto de fecha (timestamp)
SELECT finish_date, date_format(str_to_date(finish_date, '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d') AS fecha FROM limpieza; -- objeto en formato de fecha, luego da formato en el deseado '%Y-%m-%d %H:'
SELECT finish_date, str_to_date(finish_date, '%Y-%m-%d') AS fd FROM LIMPIEZA; -- separar solo la fecha
SELECT  finish_date, str_to_date(finish_date, '%H:%i:%s') AS hour_stamp FROM LIMPIEZA; -- separar solo la hora no funciona
SELECT  finish_date, date_format(finish_date, '%H:%i:%s') AS hour_stamp FROM LIMPIEZA; -- separar solo la hora(marca de tiempo)


SELECT finish_date,
    date_format(finish_date, '%H') AS hora,
    date_format(finish_date, '%i') AS minutos,
    date_format(finish_date, '%s') AS segundos,
    date_format(finish_date, '%H:%i:%s') AS hour_stamp
FROM LIMPIEZA;


ALTER TABLE limpieza ADD COLUMN date_backup TEXT; -- Agregar columna respaldo
UPDATE limpieza SET date_backup = finish_date;


SELECT finish_date, date_format(str_to_date(finish_date, '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d') AS fecha FROM limpieza;

UPDATE LIMPIEZA SET finish_date = date_format(str_to_date(finish_date, '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d')
WHERE  finish_date <>'';


ALTER TABLE LIMPIEZA
	ADD column FECHA date,
    ADD COLUMN HORA TIME;
    
CALL LIMP();

UPDATE LIMPIEZA 
SET FECHA = DATE(finish_date),
	HORA = TIME (finish_date)
WHERE finish_date IS NOT NULL AND finish_date <> '';

UPDATE LIMPIEZA SET finish_date = NULL WHERE finish_date = '';

ALTER TABLE LIMPIEZA MODIFY COLUMN finish_date DATETIME;
describe LIMPIEZA;

-- CALCULOS CON FECHAS 

ALTER TABLE LIMPIEZA ADD age int;

select name, birth_date, START_DATE, timestampdiff(year,birth_date,START_DATE ) as edad_de_ingreso from limpieza;

update limpieza 
set age = timestampdiff(year, birth_date, curdate());
CALL LIMP();

select name, birth_date, age from limpieza;

select concat(SUBSTRING_INDEX(name,' ', 1), '_', substring(last_name, 1, 2), ' ', substring(type,1,1), '@consulting.com') as email from limpieza;

alter table limpieza add column email varchar(100);
call limp();


update limpieza set email = concat(SUBSTRING_INDEX(name,' ', 1), '_', substring(last_name, 1, 2), ' ', substring(type,1,1), '@consulting.com');

-- exportando datos definitivos 

select ID_EMPLEADO, name, last_name, age, gender, area, salary, email,finish_date from LIMPIEZA;
WHERE finish_date <= curdate() or finish_date is null
order by area, name;


SELECT  area, COUNT(*) AS CANTIDAD_EMPLEADOS FROM LIMPIEZA
GROUP BY AREA
ORDER BY CANTIDAD_EMPLEADOS DESC;