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
