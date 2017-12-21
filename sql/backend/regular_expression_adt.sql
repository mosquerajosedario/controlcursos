
-----------------------------------------------------
-- PACKAGE: BACKEND -- CLASS: regular_expression   --
-----------------------------------------------------

-------------------
-- MEMBER ATRIBUTES
-------------------
CREATE TABLE regular_expression (
	name                     text NOT NULL PRIMARY KEY,
	definition               text NOT NULL UNIQUE
);
