
-----------------------------------------------------
-- PACKAGE: BACKEND -- CLASS: regular_expression   --
-----------------------------------------------------

-------------------
-- MEMBER ATRIBUTES
-------------------
CREATE TABLE regular_expression (
	name                     text NOT NULL PRIMARY KEY,
	definition               text NOT NULL UNIQUE
);

-----------------------------------------------------
-- PACKAGE: BACKEND -- CLASS: regular_expression   --
-----------------------------------------------------

------------------
-- MEMBER METHODS
------------------

------------------
-- CONSTRUCTOR
------------------
CREATE OR REPLACE FUNCTION regular_expression (
	IN p_name                  text,
	IN p_definition            text
) RETURNS void AS $$
BEGIN 
	IF EXISTS (SELECT 1 FROM regular_expression WHERE name = p_name)
		OR EXISTS (SELECT 1 FROM regular_expression WHERE definition = p_definition)
	THEN 
		RAISE EXCEPTION 'YA EXISTE UNA EXPRESIÓN REGULAR CON ESE NOMBRE / DEFINICION';
	ELSE 
		INSERT INTO regular_expression VALUES(p_name, p_definition);
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


------------------
-- DESTRUCTOR
------------------
CREATE OR REPLACE FUNCTION regular_expression_destroy (
	IN p_regular_expression  regular_expression
) RETURNS void AS
$$
	DELETE FROM regular_expression x WHERE x = p_regular_expression;
$$ LANGUAGE SQL VOLATILE STRICT
SET search_path FROM CURRENT;


--------------------
-- IDENTYFY & SEARCH
--------------------
CREATE OR REPLACE FUNCTION regular_expression_identify_by_name (
	IN p_name                text
) RETURNS regular_expression AS 
$$
	SELECT * FROM regular_expression WHERE name = p_name;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


--------------------
-- GETTERS & SETTERS
--------------------
CREATE OR REPLACE FUNCTION regular_expression_get_name(
	IN p_regular_expression  regular_expression
) RETURNS text AS
$$
	SELECT p_regular_expression.name;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION regular_expression_set_name (
	IN p_regular_expression  regular_expression,
	IN p_name                text
) RETURNS void AS $$
BEGIN 
	IF EXISTS (SELECT 1 FROM regular_expression WHERE name = p_name)
	THEN 
		RAISE EXCEPTION 'IMPOSIBLE ASIGNAR NOMBRE: YA EXISTE UNA EXPRESIÓN REGULAR CON ESE NOMBRE';
	ELSE 
		UPDATE regular_expression x SET name = p_name WHERE x = p_regular_expression;
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION regular_expression_get_definition ( 
	IN p_regular_expression  regular_expression
) RETURNS text AS
$$
	SELECT p_regular_expression.definition;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION regular_expression_set_definition (
	IN p_regular_expression  regular_expression,
	IN p_definition          text
) RETURNS void AS $$
BEGIN 
	IF EXISTS (SELECT 1 FROM regular_expression WHERE definition = p_definition)
	THEN 
		RAISE EXCEPTION 'YA EXISTE UNA EXPRESIÓN REGULAR CON ESA DEFINICIÓN';
	ELSE 
		UPDATE regular_expression x SET definition = p_definition WHERE x = p_regular_expression;
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION regular_expression_execute (
	IN p_regular_expression  regular_expression,
	IN p_string              text
) RETURNS boolean AS 
$$
	SELECT p_string ~ regular_expression_get_definition(p_regular_expression);
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;

-----------------------------------------
-- PACKAGE: BACKEND -- CLASS: Location --
-----------------------------------------

-------------------
-- MEMBER ATRIBUTES
-------------------

CREATE TABLE location (
	location_id              serial PRIMARY KEY,
	name                     text NOT NULL UNIQUE,
	address                  text,
	phone                    text,
	email                    text,
	status                   text NOT NULL CHECK(status IN('HABILITADO', 'DESHABILITADO')) 
                                  DEFAULT 'HABILITADO'
);

-----------------------------------------
-- PACKAGE: BACKEND -- CLASS: Location --
-----------------------------------------

------------------
-- MEMBER METHODS
------------------

------------------
-- CONSTRUCTOR
------------------
CREATE OR REPLACE FUNCTION location (
	IN p_name                text,
	IN p_address             text, 
	IN p_phone               text, 
	IN p_email               text
) RETURNS location AS $$
DECLARE 
	v_location               location;
BEGIN
	IF NOT EXISTS (SELECT 1 FROM location WHERE name = p_name)
	THEN 
		EXECUTE 'INSERT INTO location (name, address, phone, email)
			VALUES (''' || p_name || ''', ''' || p_address || ''', ''' || p_phone
			|| ''', ''' || p_email ||''') RETURNING *' INTO v_location;
		
		RETURN v_location;
	ELSE 
		RAISE EXCEPTION 'YA EXISTE UNA LOCACIÓN CON ESE NOMBRE';
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE
SET search_path FROM CURRENT;


------------------
-- DESTRUCTOR
------------------
CREATE OR REPLACE FUNCTION location_destroy (
	IN p_location            location
) RETURNS void AS 
$$
	DELETE FROM location x WHERE x = p_location; 
$$ LANGUAGE SQL VOLATILE STRICT
SET search_path FROM CURRENT;


--------------------
-- IDENTYFY & SEARCH
--------------------
CREATE OR REPLACE FUNCTION location_identify_by_location_id (
	IN p_location_id         integer
) RETURNS location AS
$$
	SELECT * FROM location WHERE location_id = p_location_id;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION location_identify_by_name (
	IN p_name                text
) RETURNS location AS
$$
	SELECT * FROM location WHERE name = p_name;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION location_search_by_name (
	IN p_name                text
) RETURNS SETOF location AS 
$$
	SELECT * FROM location WHERE name ilike '%' || p_name || '%';
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


--------------------
-- GETTERS & SETTERS
--------------------
CREATE OR REPLACE FUNCTION location_get_location_id (
	IN p_location            location
) RETURNS integer AS
$$
	SELECT p_location.location_id;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION location_get_name (
	IN p_location            location
) RETURNS text AS
$$
	SELECT p_location.name;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION location_get_address (
	IN p_location            location
) RETURNS text AS
$$
	SELECT p_location.address;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION location_set_address (
	IN p_location            location,
	IN p_address             text
) RETURNS void AS $$
BEGIN 
	IF EXISTS (SELECT 1 FROM location WHERE location_id = p_location.location_id)
	THEN 
		UPDATE location SET address = p_address WHERE location_id = p_location.location_id;
	ELSE 
		RAISE EXCEPTION 'NO EXISTE LA LOCACIÓN INDICADA';
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION location_get_phone (
	IN p_location            location
) RETURNS text AS
$$
	SELECT p_location.phone;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION location_set_phone (
	IN p_location            location,
	IN p_phone               text
) RETURNS void AS $$
BEGIN 
	IF EXISTS (SELECT 1 FROM location WHERE location_id = p_location.location_id)
	THEN 
		UPDATE location SET phone = p_phone WHERE location_id = p_location.location_id;
	ELSE 
		RAISE EXCEPTION 'NO EXISTE LA LOCACIÓN INDICADA';
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION location_get_email (
	IN p_location            location
) RETURNS text AS
$$
	SELECT p_location.email;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION location_set_email (
	IN p_location            location,
	IN p_email               text
) RETURNS void AS $$
BEGIN 
	IF EXISTS (SELECT 1 FROM location WHERE location_id = p_location.location_id)
	THEN 
		UPDATE location SET email = p_email WHERE location_id = p_location.location_id;
	ELSE 
		RAISE EXCEPTION 'NO EXISTE LA LOCACIÓN INDICADA';
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION location_get_status (
	IN p_location            location
) RETURNS text AS
$$
	SELECT p_location.status
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION location_enable_location (
	IN p_location            location
) RETURNS void AS $$
BEGIN 
	IF EXISTS (SELECT 1 FROM location x WHERE x = p_location)
	THEN 
		UPDATE location SET status = 'HABILITADO' WHERE location_id = p_location.location_id;
	ELSE 
		RAISE EXCEPTION 'LA LOCACIÓN INDICADA NO EXISTE';
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION location_disable_location (
	IN p_location            location
) RETURNS void AS $$
BEGIN 
	IF EXISTS (SELECT 1 FROM location x WHERE x = p_location)
	THEN 
		UPDATE location SET status = 'DESHABILITADO' WHERE location_id = p_location.location_id;
	ELSE 
		RAISE EXCEPTION 'LA LOCACIÓN INDICADA NO EXISTE';
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


-----------------------------------------
-- PACKAGE: BACKEND -- CLASS: Course   --
-----------------------------------------

---------------------------
-- SETUP AND CONFIGURATIONS
---------------------------
CREATE TYPE subject_name AS ENUM ('Técnicas de Programación', 'Desarrollo de Software', 
	'Programación Orientada a Objetos', 'Base de Datos');

-- EXPRESIÓN REGULAR PARA VALIDAR EL AGENDAMIETO. EL FORMATO VÁLIDO ES
-- L POR LUNES
-- M POR MARTES
-- X POR MIERCOLES
-- J POR JUEVES
-- V POR VIERNES
-- S POR SABADO
-- ADYACENTE AL DÍA DE LA SEMANA VA EL HORARIO DE ENTRADA, UNA / Y EL HORARIO DE SALIDA.
-- LOS HORARIOS VÁLIDOS VAN DE 08:00hs A 22:00hs ACEPTÁNDOSE 30 O 00 PARA LOS MINUTOS
-- PUEDEN EXISTIR DE 1 A 3 DÍAS DE CURSADA POR SEMANA. EN CASO DE CURSARSE MAS DE UN DÍA
-- POR SEMANA LOS DATOS SE SEPARAN CON UN ESPACIO EN BLANCO
-- EJEMPLO: L13:00HS/16:00HS X13:00hs/16:00hs V13:00hs/16:00hs
SELECT regular_expression (
	'course_schedule', 
	'^([" "]{0,1}[LMXJVS]{1}(0[8-9]|1[0-9]){1}'
	|| '[":"]{1}[03]{1}[0]{1}(hs){1}["\/"]{1}(0[8-9]|1[0-9]|2[0-2]){1}'
	|| '[":"]{1}[03]{1}[0]{1}(hs){1}){1,3}$'
);


-- EXPRESIÓN REGULAR PARA VALIDAR EL CÓDIGO DEL CURSO. EL MISMO ESTÁ COMPUESTO UN NÚMERO PAR,
-- SEGUIDO DE UNA / Y OTRO NÚMERO PAR.
-- EJEMPLO: 12345/67890
SELECT regular_expression ( 
	'course_id', 
	'^[0-9]+["\/"]{1}[0-9]+$'
);

-----------------------------------------
-- PACKAGE: BACKEND -- CLASS: Course   --
-----------------------------------------

-------------------
-- MEMBER ATRIBUTES
-------------------
CREATE TABLE subject (
	name                               subject_name NOT NULL, 
	allocated_hours                    real NOT NULL CHECK (allocated_hours > 0),
	consumed_hours                     real CHECK(consumed_hours < allocated_hours) DEFAULT 0
);

CREATE TABLE course (
	course_id                          text PRIMARY KEY CHECK(course_id ~ regular_expression_get_definition(
	                                     regular_expression_identify_by_name('course_id'))),
	begin_date                         date NOT NULL,
	end_date                           date CHECK (end_date > begin_date),
	schedule                           text NOT NULL CHECK(schedule ~ regular_expression_get_definition(
	                                     regular_expression_identify_by_name('course_schedule'))),
	subjects                           subject[],
	status                             text NOT NULL CHECK(status IN('INSCRIBIENDO ALUMNOS', 
	                                     'EN CURSO', 'FINALIZADO', 'CANCELADO')) 
	                                     DEFAULT 'INSCRIBIENDO ALUMNOS'
);

CREATE TABLE course_location_association (
	course_location_association_id     serial PRIMARY KEY,
	course_id                          text NOT NULL REFERENCES course(course_id) UNIQUE,
	location_id                        integer NOT NULL REFERENCES location(location_id)
);

-----------------------------------------
-- PACKAGE: BACKEND -- CLASS: Course --
-----------------------------------------

------------------
-- MEMBER METHODS
------------------

------------------
-- CONSTRUCTOR
------------------
CREATE OR REPLACE FUNCTION course (
	IN p_course_id           text,
	IN p_begin_date          date,
	IN p_schedule            text
) RETURNS course AS $$
DECLARE 
	new_course               course;
BEGIN
	IF NOT regular_expression_execute (
		regular_expression_identify_by_name('course_id'), p_course_id)
	THEN 
		RAISE EXCEPTION 'EL FORMATO DE ID DE CURSO ES INCORRECTO';
	END IF;
	
	IF EXISTS (SELECT 1 FROM course WHERE course_id = p_course_id)
	THEN 
		RAISE EXCEPTION 'YA EXISTE UN CURSO CON ESE ID';
	END IF;
	
	IF NOT regular_expression_execute (
		regular_expression_identify_by_name('course_schedule'), p_schedule)
    THEN 
		RAISE EXCEPTION 'EL FORMATO DE AGENDAMIENTO NO ES CORRECTO';
	END IF;
	
	EXECUTE 'INSERT INTO COURSE (course_id, begin_date, schedule)
		VALUES(''' || p_course_id || ''', ''' || p_begin_date || ''', ''' || p_schedule || 
		''') RETURNING *'
	INTO new_course;
	
	RETURN new_course;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


------------------
-- DESTRUCTOR
------------------
CREATE OR REPLACE FUNCTION course_detroy (
	IN p_course              course
) RETURNS void AS
$$
	DELETE FROM course x WHERE x = p_course;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


--------------------
-- IDENTYFY & SEARCH
--------------------
CREATE OR REPLACE FUNCTION course_identify_by_course_id (
	IN p_course_id           text
) RETURNS course AS
$$
	SELECT * FROM course WHERE course_id = p_course_id;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION course_search_by_schedule (
	IN p_schedule            text
) RETURNS SETOF course AS
$$
	SELECT * FROM COURSE WHERE schedule = p_schedule
		ORDER BY 1;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION course_lookup_by_location (
	IN p_location            location
) RETURNS SETOF course AS 
$$
	SELECT 
		a.* 
	FROM 
		course a
		INNER JOIN course_location_association b USING(course_id)
		INNER JOIN location c USING(location_id)
	WHERE 
		c = p_location
	ORDER BY 1;
$$ LANGUAGE SQL STABLE STRICT 
SET search_path FROM CURRENT;


--------------------
-- GETTERS & SETTERS
--------------------
CREATE OR REPLACE FUNCTION course_get_course_id (
	IN p_course              course
) RETURNS text AS 
$$
	SELECT p_course.course_id;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION course_get_begin_date (
	IN p_course              course
) RETURNS date AS 
$$
	SELECT p_course.begin_date;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION course_get_end_date (
	IN p_course              course
) RETURNS date AS 
$$
	SELECT p_course.end_date;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION course_get_schedule (
	IN p_course              course
) RETURNS text AS 
$$
	SELECT p_course.schedule;
$$ LANGUAGE SQL STABLE STRICT 
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION course_set_schedule (
	IN p_course              course,
	IN p_schedule            text
) RETURNS void AS $$
BEGIN 
	IF NOT regular_expression_execute (
		regular_expression_identify_by_name('course_schedule'), p_schedule)
    THEN 
		RAISE EXCEPTION 'EL FORMATO DE AGENDAMIENTO NO ES CORRECTO';
	ELSE
		UPDATE course x SET schedule = p_schedule WHERE x = p_course;
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION course_finish_course (
	IN p_course              course
) RETURNS void AS $$
BEGIN 
	IF NOT EXISTS(SELECT 1 FROM course x WHERE x = p_course)
	THEN 
		RAISE EXCEPTION 'EL CURSO INDICADO NO EXISTE';
	ELSIF p_course.status != 'EN CURSO' 
	THEN 
		RAISE EXCEPTION 'IMPOSIBLE CAMBIAR EL ESTADO DEL CURSO A "FINALIZADO" DESDE EL ESTADO ACTUAL';
	ELSE
		UPDATE course x SET (status, end_date) = ('FINALIZADO', current_date) WHERE x = p_course;
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION course_start_course (
	IN p_course              course
) RETURNS void AS $$
BEGIN 
	IF NOT EXISTS(SELECT 1 FROM course x WHERE x = p_course)
	THEN 
		RAISE EXCEPTION 'EL CURSO INDICADO NO EXISTE';
	ELSIF p_course.status != 'INSCRIBIENDO ALUMNOS' 
	THEN 
		RAISE EXCEPTION 'IMPOSIBLE CAMBIAR EL ESTADO DEL CURSO A "EN CURSO" DESDE EL ESTADO ACTUAL';
	ELSE
		UPDATE course x SET status = 'EN CURSO' WHERE x = p_course;
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION course_cancel_course (
	IN p_course              course
) RETURNS void AS $$
BEGIN 
	IF NOT EXISTS(SELECT 1 FROM course x WHERE x = p_course)
	THEN 
		RAISE EXCEPTION 'EL CURSO INDICADO NO EXISTE';
	ELSIF p_course.status = 'CANCELADO' 
	THEN 
		RAISE EXCEPTION 'IMPOSIBLE CAMBIAR EL ESTADO DEL CURSO A "CANCELADO" DESDE EL ESTADO ACTUAL';
	ELSE
		UPDATE course x SET (status, end_date) = ('CANCELADO', current_date) WHERE x = p_course;
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION course_set_location (
	IN p_course              course,
	IN p_location            location
) RETURNS void AS $$
BEGIN 
	IF NOT EXISTS(SELECT 1 FROM course x WHERE x = p_course)
		OR NOT EXISTS(SELECT 1 FROM location x WHERE x = p_location)
	THEN 
		RAISE EXCEPTION 'EL CURSO O LA LOCACIÓN SOLICITADA NO EXISTEN';
	ELSE 
		INSERT INTO course_location_association(course_id, location_id)
			VALUES(p_course.course_id, p_location.location_id)
		ON CONFLICT (course_id) DO
			UPDATE SET location_id = EXCLUDED.location_id;
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION course_unset_location (
	p_course                 course
) RETURNS void AS $$
BEGIN 
	IF NOT EXISTS(SELECT 1 FROM course x WHERE x = p_course)
	THEN 
		RAISE EXCEPTION 'EL CURSO INDICADO NO EXISTE';
	ELSIF NOT EXISTS(SELECT 1 FROM course_location_association 
		WHERE course_id = p_course.course_id) 
	THEN 
		RAISE EXCEPTION 'EL CURSO INDICADO NO TIENE LOCACIÓN ASIGNADA';
	ELSE 
		DELETE FROM course_location_association WHERE course_id = p_course.course_id;
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;

-----------------------------------------
-- PACKAGE: BACKEND -- CLASS: Course   --
-----------------------------------------

-----------------------------
-- BUSINESS RULES AND OBJECTS
-----------------------------

CREATE OR REPLACE FUNCTION course_location_association_trg()
RETURNS trigger AS $$
DECLARE 
	location_status          text;
	course_status            text;
BEGIN 
	location_status := status FROM location WHERE location_id = NEW.location_id;
	course_status := status FROM course WHERE course_id = NEW.course_id;
	
	IF location_status = 'DESHABILITADO' OR course_status IN('FINALIZADO', 'CANCELADO')
	THEN 
		RAISE EXCEPTION 'LAS REGLAS DE NEGOCIO VIGENTES IMPIDEN ASOCIAR EL CURSO CON LA LOCACION SOLICITADOS';
		RETURN NULL;
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE PLpgSQL;


CREATE TRIGGER course_location_association_trg BEFORE INSERT OR UPDATE ON course_location_association
	FOR EACH ROW EXECUTE PROCEDURE course_location_association_trg();


CREATE OR REPLACE VIEW vw_course_location_association AS
	SELECT 
		course_location_association_id,
		course_identify_by_course_id(course_id) AS course,
		location_identify_by_location_id(location_id) AS location
	FROM 
		course_location_association;

CREATE OR REPLACE RULE prevent_insert_to_subject AS
	ON INSERT TO subject DO INSTEAD NOTHING;
------------------------------------------------
-- PACKAGE: GUI -- REFERENCED CLASS: Location --
------------------------------------------------

------------------
-- HELPERS
------------------
CREATE OR REPLACE FUNCTION gui_location_add_location (
	p_location               jsonb
) RETURNS jsonb AS $$
DECLARE 
	v_name                   text;
	v_address                text;
	v_phone                  text;
	v_email                  text;
BEGIN 
	IF NOT gui_location_is_json_location_valid(p_location)
	THEN
		RAISE EXCEPTION 'JSON DE LOCACIÓN INVÁLIDO';
	END IF;
	
	v_name := p_location ->> 'name';
	v_address := p_location ->> 'address';
	v_phone := p_location ->> 'phone';
	v_email := p_location ->> 'email';
	
	RETURN row_to_json(x) FROM (SELECT * FROM location(v_name, v_address, v_phone, v_email)) x;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION gui_location_update_location (
	p_location               jsonb
) RETURNS void AS $$
DECLARE 
	v_location_id            integer;
	v_name                   text;
	v_address                text;
	v_phone                  text;
	v_email                  text;
	v_status                 text;
BEGIN 
	IF NOT gui_location_is_json_location_valid(p_location)
	THEN
		RAISE EXCEPTION 'JSON DE LOCACIÓN INVÁLIDO';
	END IF;
	
	v_location_id := (p_location ->> 'location_id')::text::integer;
	v_name := p_location ->> 'name';
	v_address := p_location ->> 'address';
	v_phone := p_location ->> 'phone';
	v_email := p_location ->> 'email';
	v_status := p_location ->> 'status';
	
	IF NOT EXISTS (SELECT 1 FROM location WHERE location_id = v_location_id)
	THEN 
		RAISE EXCEPTION 'LA LOCACIÓN INDICADA NO EXISTE';
	ELSE
		PERFORM location_set_address(location_identify_by_location_id(v_location_id), v_address);
		PERFORM location_set_phone(location_identify_by_location_id(v_location_id), v_phone);
		PERFORM location_set_email(location_identify_by_location_id(v_location_id), v_email);
		
		IF status(location_identify_by_location_id(v_location_id)) != v_status
		THEN 
			IF v_status = 'HABILITADO'
			THEN 
				PERFORM location_enable_location(location_identify_by_location_id(v_location_id));
			ELSIF v_status = 'DESHABILITADO'
			THEN
				PERFORM location_disable_location(location_identify_by_location_id(v_location_id));
			END IF;
		END IF;
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION gui_location_destroy_location (
	IN p_location_id         jsonb
) RETURNS void AS $$
DECLARE 
	v_location_id            integer;
BEGIN
	IF NOT p_location_id ? 'location_id'
	THEN 
		RAISE EXCEPTION 'LOCATION ID INVÁLIDO';
	END IF;
	
	v_location_id := (p_location_id ->> 'location_id')::text::integer;
	
	IF location_identify_by_location_id(v_location_id) IS NULL
	THEN 
		RAISE EXCEPTION 'LA LOCACIÓN INDICADA NO EXISTE';
	ELSE 
		PERFORM location_destroy(location_identify_by_location_id(v_location_id));
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION gui_location_list_all_locations()
RETURNS json AS 
$$
	SELECT array_to_json(array_agg(row_to_json(x))) 
		FROM (SELECT * FROM location ORDER BY name) x;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION gui_location_list_enabled_locations()
RETURNS json AS 
$$
	SELECT array_to_json(array_agg(row_to_json(x))) 
		FROM (SELECT * FROM location WHERE status = 'HABILITADO' ORDER BY name) x;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION gui_location_is_json_location_valid (
	p_location               jsonb
) RETURNS boolean AS $$
BEGIN 
	IF p_location ? 'name' AND p_location ? 'address' AND p_location ? 'phone' 
		AND p_location ? 'email' AND p_location ? 'status' 
		AND p_location ->> 'status' IN ('HABILITADO', 'DESHABILITADO')
	THEN
		RETURN TRUE;
	ELSE 
		RETURN FALSE;
	END IF;
END;
$$ LANGUAGE PLpgSQL STABLE STRICT
SET search_path FROM CURRENT;
------------------------------------------------
-- PACKAGE: GUI -- REFERENCED CLASS: Course   --
------------------------------------------------

------------------
-- HELPERS
------------------
