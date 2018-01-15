import tkinter as tk
from tkinter import messagebox as mb
from tkinter import simpledialog as sd
from tkinter import ttk
from bfagui import bfaform
from bfagui import bfabutton
import json

class CourseMainForm(bfaform.GridForm):
	def __init__(self, master, pgConnection, behavior = "main"):
		querys = {"mainQuery":"gui_course_list_all_courses()", "searchQuery":"gui_course_list_enabled_locations()"}
		setup = {"title":"Administración de Cursos", "formHeight":200, "icon":"./img/curso.png", "querys":querys}
		gridColumns = {"Comisión":100, "Fecha Inicio":120, "Fecha Fin":120, "Horarios":250, "Locación":250, "Estado":200}
		
		bfaform.GridForm.__init__(self, master, pgConnection, setup, gridColumns, behavior)
		
		self.__courseMenu = tk.Menu(self._mainMenu, tearoff = 0)
		self.__courseMenu.add_command(label = "Alta de curso", command = self.createCourse)
		self.__courseMenu.add_command(label = "Modificar curso")
		self.__courseMenu.add_separator()
		self.__courseMenu.add_command(label = "Baja de curso")
		self._mainMenu.add_cascade(label = "Cursos", menu = self.__courseMenu)
		
	def updateGrid(self):
		self.getData()
		
		if self._items != None:
			for course in self._items:
				self._dbGrid.insert('', 'end', text = course["course_id"], values=(course["begin_date"], \
				  course["end_date"], course["schedule"], course["location"], course["status"]))
	
	def createCourse(self):
		setup = {"title":"Alta de Curso", "geometry":"400x500", "icon":"./img/curso.png"}
		fields = {"Comisión":45, "Fecha Inicio":45, "Fecha Fin":45, "Horarios":45, "Locación":45, "Estado":45}
		
		createCourseForm = bfaform.EditForm(self, setup, fields, "add")
		createCourseForm.toDropDown("Locación", ["Velodromo", "Fundacion Pupi", "Nido Chingolo"], "Velodromo")
		
		createCourseForm.setEntryValue("Estado", "INSCRIBIENDO ALUMNOS")
		
		createCourseForm.disableEntry({"Fecha Fin", "Estado"})
		
		createCourseForm.setFocus("Comisión")
