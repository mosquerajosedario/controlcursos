
---------------------
-- CLASS: location --
---------------------

------------------
-- DEFINITION
------------------

CREATE TABLE location (
	location_id              serial PRIMARY KEY,
	name                     text NOT NULL UNIQUE,
	address                  text,
	phone                    text,
	email                    text,
	status                   text NOT NULL CHECK(status IN('HABILITADO', 'DESHABILITADO')) 
                                  DEFAULT 'HABILITADO'
);


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
-- DESSTRUCTOR
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


------------------
-- GUI
------------------
CREATE OR REPLACE FUNCTION location_gui_add_location (
	p_location               jsonb
) RETURNS jsonb AS $$
DECLARE 
	v_name                   text;
	v_address                text;
	v_phone                  text;
	v_email                  text;
BEGIN 
	IF NOT location_gui_is_json_location_valid(p_location)
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


CREATE OR REPLACE FUNCTION location_gui_update_location (
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
	IF NOT location_gui_is_json_location_valid(p_location)
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


CREATE OR REPLACE FUNCTION location_gui_destroy_location (
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


CREATE OR REPLACE FUNCTION location_gui_list_all_locations()
RETURNS json AS 
$$
	SELECT array_to_json(array_agg(row_to_json(x))) 
		FROM (SELECT * FROM location ORDER BY name) x;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION location_gui_list_enabled_locations()
RETURNS json AS 
$$
	SELECT array_to_json(array_agg(row_to_json(x))) 
		FROM (SELECT * FROM location WHERE status = 'HABILITADO' ORDER BY name) x;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION location_gui_is_json_location_valid (
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

