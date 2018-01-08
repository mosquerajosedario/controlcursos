SHELL = /bin/sh

.PHONY: clean

all: gui.sql

gui.sql: gui_location_fns.sql \
	gui_course_fns.sql
	
	for sqlFile in $^; do cat $$sqlFile >> gui.sql; done

clean:
	$(RM) gui.sql
