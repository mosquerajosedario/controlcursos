

-----------------------------------------
-- PACKAGE: BACKEND -- CLASS: Course   --
-----------------------------------------

---------------------------
-- SETUP AND CONFIGURATIONS
---------------------------

-- EXPRESIÓN REGULAR PARA VALIDAR EL AGENDAMIETO. EL FORMATO VÁLIDO ES
-- L POR LUNES
-- M POR MARTES
-- X POR MIERCOLES
-- J POR JUEVES
-- V POR VIERNES
-- S POR SABADO
-- ADYACENTE AL DÍA DE LA SEMANA VA EL HORARIO DE ENTRADA, UNA / Y EL HORARIO DE SALIDA.
-- LOS HORARIOS VÁLIDOS VAN DE 08:00hs A 22:00hs ACEPTÁNDOSE 30 O 00 PARA LOS MINUTOS
-- PUEDEN EXISTIR DE 1 A 3 DÍAS DE CURSADA POR SEMANA. EN CASO DE CURSARSE MAS DE UN DÍA
-- POR SEMANA LOS DATOS SE SEPARAN CON UN ESPACIO EN BLANCO
-- EJEMPLO: L13:00HS/16:00HS X13:00hs/16:00hs V13:00hs/16:00hs
SELECT regular_expression (
	'course_schedule', 
	'^([" "]{0,1}[LMXJVS]{1}(0[8-9]|1[0-9]){1}'
	|| '[":"]{1}[03]{1}[0]{1}(hs){1}["\/"]{1}(0[8-9]|1[0-9]|2[0-2]){1}'
	|| '[":"]{1}[03]{1}[0]{1}(hs){1}){1,3}$'
);


-- EXPRESIÓN REGULAR PARA VALIDAR EL CÓDIGO DEL CURSO. EL MISMO ESTÁ COMPUESTO UN NÚMERO PAR,
-- SEGUIDO DE UNA / Y OTRO NÚMERO PAR.
-- EJEMPLO: 12345/67890
SELECT regular_expression ( 
	'course_id', 
	'^[0-9]+["\/"]{1}[0-9]+$'
)
