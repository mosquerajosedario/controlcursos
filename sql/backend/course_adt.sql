
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
