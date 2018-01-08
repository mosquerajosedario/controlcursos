
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
