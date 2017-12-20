
-----------------------------------------
-- PACKAGE: BACKEND -- CLASS: Course   --
-----------------------------------------

-------------------
-- MEMBER ATRIBUTES
-------------------
CREATE TABLE course (
	course_id                text PRIMARY KEY,
	begin_date               date NOT NULL,
	end_date                 date,
	location_id              integer NOT NULL REFERENCES location(location_id),
	schedule                 text NOT NULL,
	status                   text NOT NULL CHECK(status IN('INSCRIBIENDO ALUMNOS', 
	                           'EN CURSO', 'FINALIZADO', 'CANCELADO')) 
	                           DEFAULT 'INSCRIBIENDO ALUMNOS'
);
