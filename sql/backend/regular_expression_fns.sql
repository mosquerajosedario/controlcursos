
-----------------------------------------------------
-- PACKAGE: BACKEND -- CLASS: regular_expression   --
-----------------------------------------------------

------------------
-- MEMBER METHODS
------------------

------------------
-- CONSTRUCTOR
------------------
CREATE OR REPLACE FUNCTION regular_expression (
	IN p_name                  text,
	IN p_definition            text
) RETURNS void AS $$
BEGIN 
	IF EXISTS (SELECT 1 FROM regular_expression WHERE name = p_name)
		OR EXISTS (SELECT 1 FROM regular_expression WHERE definition = p_definition)
	THEN 
		RAISE EXCEPTION 'YA EXISTE UNA EXPRESIÓN REGULAR CON ESE NOMBRE / DEFINICION';
	ELSE 
		INSERT INTO regular_expression VALUES(p_name, p_definition);
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


------------------
-- DESTRUCTOR
------------------
CREATE OR REPLACE FUNCTION regular_expression_destroy (
	IN p_regular_expression  regular_expression
) RETURNS void AS
$$
	DELETE FROM regular_expression x WHERE x = p_regular_expression;
$$ LANGUAGE SQL VOLATILE STRICT
SET search_path FROM CURRENT;


--------------------
-- IDENTYFY & SEARCH
--------------------
CREATE OR REPLACE FUNCTION regular_expression_identify_by_name (
	IN p_name                text
) RETURNS regular_expression AS 
$$
	SELECT * FROM regular_expression WHERE name = p_name;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


--------------------
-- GETTERS & SETTERS
--------------------
CREATE OR REPLACE FUNCTION regular_expression_get_name(
	IN p_regular_expression  regular_expression
) RETURNS text AS
$$
	SELECT p_regular_expression.name;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION regular_expression_set_name (
	IN p_regular_expression  regular_expression,
	IN p_name                text
) RETURNS void AS $$
BEGIN 
	IF EXISTS (SELECT 1 FROM regular_expression WHERE name = p_name)
	THEN 
		RAISE EXCEPTION 'IMPOSIBLE ASIGNAR NOMBRE: YA EXISTE UNA EXPRESIÓN REGULAR CON ESE NOMBRE';
	ELSE 
		UPDATE regular_expression x SET name = p_name WHERE x = p_regular_expression;
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION regular_expression_get_definition ( 
	IN p_regular_expression  regular_expression
) RETURNS text AS
$$
	SELECT p_regular_expression.definition;
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION regular_expression_set_definition (
	IN p_regular_expression  regular_expression,
	IN p_definition          text
) RETURNS void AS $$
BEGIN 
	IF EXISTS (SELECT 1 FROM regular_expression WHERE definition = p_definition)
	THEN 
		RAISE EXCEPTION 'YA EXISTE UNA EXPRESIÓN REGULAR CON ESA DEFINICIÓN';
	ELSE 
		UPDATE regular_expression x SET definition = p_definition WHERE x = p_regular_expression;
	END IF;
END;
$$ LANGUAGE PLpgSQL VOLATILE STRICT
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION regular_expression_execute (
	IN p_regular_expression  regular_expression,
	IN p_string              text
) RETURNS boolean AS 
$$
	SELECT p_string ~ regular_expression_get_definition(p_regular_expression);
$$ LANGUAGE SQL STABLE STRICT
SET search_path FROM CURRENT;
