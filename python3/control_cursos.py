#!/usr/bin/env python3

import tkinter as tk
from tkinter import messagebox as mb
from bfadbdriver import pgdriver
from bfagui import bfaform
import location
import course

def login():
	while True:
		userPassword = bfaform.login()
		
		try:
			pgConnection = pgdriver.PGConnection(userPassword["userName"], userPassword["password"])
			return pgConnection
		except:
			print("Error de inicio de sesión")

def showLocationForm():
	locationForm = location.LocationMainForm(mainForm, pgConnection, behavior = "main")
	locationForm.grab_set()
	mainForm.wait_window(locationForm)

def showCourseForm():
	courseForm = course.CourseMainForm(mainForm, pgConnection, behavior = "main")
	courseForm.grab_set()
	mainForm.wait_window(courseForm)

pgConnection = login()

root = tk.Tk()
mainForm = bfaform.BaseForm(root, title = "Control de Cursos", icon = "./img/curso.png")

administrationMenu = tk.Menu(mainForm._mainMenu, tearoff = 0)
administrationMenu.add_command(label = "Gestionar locaciones", command = showLocationForm)
administrationMenu.add_command(label = "Gestionar cursos", command = showCourseForm)
mainForm._mainMenu.add_cascade(label = "Administración", menu = administrationMenu)

root.mainloop()
