SHELL = /bin/sh

.PHONY: clean

all: backend.sql

backend.sql: regular_expression_adt.sql \
	regular_expression_fns.sql \
	location_adt.sql \
	location_fns.sql \
	course_stp.sql \
	course_adt.sql \
	course_fns.sql \
	course_bro.sql
	
	for sqlFile in $^; do cat $$sqlFile  >> backend.sql; done

clean:
	$(RM) backend.sql
