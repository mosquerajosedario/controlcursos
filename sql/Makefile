SHELL = /bin/sh

.PHONY: clean \
	backend/backend.sql \
	gui/gui.sql

all: control_cursos.sql

control_cursos.sql: backend/backend.sql \
	gui/gui.sql
	
	cat backend/backend.sql >> control_cursos.sql
	cat gui/gui.sql >> control_cursos.sql

backend/backend.sql:
	$(MAKE) -C backend

gui/gui.sql:
	$(MAKE) -C gui

clean:
	$(MAKE) -C gui clean
	$(MAKE) -C backend clean
	$(RM) control_cursos.sql
