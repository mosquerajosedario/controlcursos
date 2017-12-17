CREATE TABLE course (
	course_id                text PRIMARY KEY,
	begin_date               date NOT NULL,
	end_date                 date,
	location                 text NOT NULL,
	schedule                 text NOT NULL,
	apointed_students        student[],
	status                   text NOT NULL CHECK(status IN('INSCRIBIENDO ALUMNOS', 
	                           'EN CURSO', 'FINALIZADO', 'CANCELADO')) 
	                           DEFAULT 'INSCRIBIENDO ALUMNOS'
);


CREATE OR REPLACE FUNCTION course (
	IN p_course_id           text,
	IN p_begin_date          date,
	IN p_location            text,
	IN p_schedule            text
) RETURNS course AS $$
BEGIN 
	IF NOT EXISTS (SELECT 1 FROM course WHERE course_id = p_course_id)
	THEN 
		INSERT INTO COURSE (course_id, begin_date, location, schedule)
			VALUES(p_course_id, p_begin_date, p_location, p_schedule);
	ELSE 
		RAISE EXCEPTION 'YA EXISTE UN CURSO CON ESE ID';
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION course_identify_by_course_id (
	IN p_course_id           text
) RETURNS course AS
$$
	SELECT * FROM course WHERE course_id = p_course_id;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION 
