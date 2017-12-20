CREATE TABLE student (
	dni                      integer PRIMARY KEY,
	name                     text NOT NULL,
	birthday                 date NOT NULL,
	address                  text,
	email                    text NOT NULL,
	phone                    text NOT NULL,
	status                   text NOT NULL CHECK (status IN('ACTIVO', 'INACTIVO', 'EGRESADO'))
);


CREATE OR REPLACE FUNCTION student (
	IN p_dni                 text,
	IN p_name                text,
	IN p_birthday            date,
	IN p_email               text,
	IN p_phone               text,
	IN p_address             text DEFAULT NULL
) RETURNS student AS
$$
BEGIN 
	IF NOT EXISTS (SELECT 1 FROM student WHERE dni = p_dni)
	THEN
		INSERT INTO student VALUES
			(p_dni, p_name, p_surname, p_birthday, p_address, p_email, p_phone, 'ACTIVO')
		RETURNING *;
	ELSE 
		RAISE EXCEPTION 'YA EXISTE UN ALUMNO CON EL DNI %', p_dni;
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION student_identify_by_dni (
	IN p_dni                 integer
) RETURNS student AS
$$
	SELECT * FROM student WHERE dni = p_dni;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION student_lookup_by_name (
	IN p_name               text
) RETURNS SETOF student AS
$$
	SELECT * FROM student WHERE name = p_name;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION student_find_by_name (
	IN p_name                text
) RETURNS SETOF student AS
$$
	SELECT * FROM student WHERE name ILIKE '%' || p_name || '%';
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION student_get_dni (
	IN p_student             student
) RETURNS integer AS
$$
	SELECT p_student.dni;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION student_get_name (
	IN p_student             student
) RETURNS text AS
$$
	SELECT p_student.name;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;

CREATE OR REPLACE FUNCTION student_get_birthday (
	IN p_student             student
) RETURNS date AS
$$
	SELECT p_student.birthday;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION student_get_address (
	IN p_student             student
) RETURNS text AS
$$
	SELECT p_student.address;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION student_set_address (
	IN p_student             student,
	IN p_address             text
) RETURNS void AS $$
BEGIN
	IF EXISTS (SELECT 1 FROM student WHERE student = p_student)
	THEN
		UPDATE student SET address = p_address WHERE dni = p_student.dni;
	ELSE 
		RAISE EXCEPTION 'EL ALUMNO INDICADO NO EXISTE';
	END IF;
END;
$$ LANGUAGE PLpgSQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION student_get_email (
	IN p_student             student
) RETURNS text AS
$$
	SELECT p_student.email;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION student_set_email (
	IN p_student             student,
	IN p_email               text
) RETURNS void AS $$
BEGIN
	IF EXISTS (SELECT 1 FROM student WHERE student = p_student)
	THEN
		UPDATE student SET email = p_email WHERE dni = p_student.dni;
	ELSE 
		RAISE EXCEPTION 'EL ALUMNO INDICADO NO EXISTE';
	END IF;
END;
$$ LANGUAGE PLpgSQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION student_get_phone (
	IN p_student             student
) RETURNS text AS
$$
	SELECT p_student.phone;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION student_set_phone (
	IN p_student             student,
	IN p_phone               text
) RETURNS void AS $$
BEGIN
	IF EXISTS (SELECT 1 FROM student WHERE student = p_student)
	THEN
		UPDATE student SET phone = p_phone WHERE dni = p_student.dni;
	ELSE 
		RAISE EXCEPTION 'EL ALUMNO INDICADO NO EXISTE';
	END IF;
END;
$$ LANGUAGE PLpgSQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION student_get_status (
	IN p_student             student
) RETURNS text AS
$$
	SELECT p_student.status;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION student_change_status (
	IN p_student             student
) RETURNS void AS $$
BEGIN
	IF EXISTS (SELECT 1 FROM student WHERE student = p_student)
	THEN
		IF p_student.status = 'ACTIVO'
		THEN
			UPDATE student SET status = 'INACTIVO' WHERE dni = p_student.dni;
		ELSE 
			UPDATE student SET status = 'ACTIVO' WHERE dni = p_student.dni;
		END IF;
	ELSE 
		RAISE EXCEPTION 'EL ALUMNO INDICADO NO EXISTE';
	END IF;
END;
$$ LANGUAGE PLpgSQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION student_is_active (
	IN p_student             student
) RETURNS boolean AS
$$
	SELECT p_student.status = 'ACTIVO';
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;
