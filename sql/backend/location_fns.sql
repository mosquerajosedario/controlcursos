
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
