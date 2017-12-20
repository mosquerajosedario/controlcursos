
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
	IN p_location_id         integer,
	IN p_schedule            text
) RETURNS course AS $$
BEGIN 
	IF EXISTS (SELECT 1 FROM course WHERE course_id = p_course_id)
	THEN 
		RAISE EXCEPTION 'YA EXISTE UN CURSO CON ESE ID';
	END IF;
    
	IF NOT EXISTS(SELECT 1 FROM location WHERE location_id = p_location_id)
	THEN 
		RAISE EXCEPTION 'LA LOCACIÓN INDICADA NO EXISTE';
	END IF;
	
	INSERT INTO COURSE (course_id, begin_date, location, schedule)
		VALUES(p_course_id, p_begin_date, p_location, p_schedule);
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


------------------
-- DESTRUCTOR
------------------


CREATE OR REPLACE FUNCTION course_identify_by_course_id (
	IN p_course_id           text
) RETURNS course AS
$$
	SELECT * FROM course WHERE course_id = p_course_id;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION 
