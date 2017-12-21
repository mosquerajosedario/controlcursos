
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
