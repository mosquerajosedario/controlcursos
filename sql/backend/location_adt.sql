
-----------------------------------------
-- PACKAGE: BACKEND -- CLASS: Location --
-----------------------------------------

-------------------
-- MEMBER ATRIBUTES
-------------------

CREATE TABLE location (
	location_id              serial PRIMARY KEY,
	name                     text NOT NULL UNIQUE,
	address                  text,
	phone                    text,
	email                    text,
	status                   text NOT NULL CHECK(status IN('HABILITADO', 'DESHABILITADO')) 
                                  DEFAULT 'HABILITADO'
);
