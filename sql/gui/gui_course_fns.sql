------------------------------------------------
-- PACKAGE: GUI -- REFERENCED CLASS: Course   --
------------------------------------------------

------------------
-- HELPERS
------------------

CREATE OR REPLACE FUNCTION gui_course_list_all_courses()
RETURNS json AS
$$
	SELECT 
		array_to_json(array_agg(row_to_json(x))) 
	FROM (
		SELECT 
			(course).course_id, 
			(course).begin_date, 
			(course).end_date, 
			(course).schedule, 
			(location).name AS location, 
			(course).status 
		FROM 
			vw_course_location_association 
		ORDER BY 1
	) x;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION gui_course_list_enabled_locations()
RETURNS json AS 
$$
	SELECT array_to_json(array_agg(row_to_json(x))) 
		FROM (
			SELECT 
				(course).course_id, 
				(course).begin_date, 
				(course).end_date, 
				(course).schedule, 
				(location).name AS location, 
				(course).status 
			FROM 
				vw_course_location_association
			WHERE 
				(course).status NOT IN('FINALIZADO', 'CANCELADO') 
			ORDER BY 1
		) x;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;
