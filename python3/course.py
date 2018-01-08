import tkinter as tk
from tkinter import messagebox as mb
from tkinter import simpledialog as sd
from tkinter import ttk
from bfagui import bfaform
from bfagui import bfabutton
import json

class CourseMainForm(bfaform.CustomForm):
	def __init__(self, master, pgConnection, behavior = "main"):
		self.__behavior = behavior
		self.__pgConnection = pgConnection
		
		bfaform.CustomForm.__init__(self, master, "Administración de Cursos", "1065x130", "./img/curso.png")
		
		self.__dbGrid = ttk.Treeview(self, height = 5)
		self.__dbGrid.place(x = 5, y = 5)
		self.__verticalScrollBar = ttk.Scrollbar(self, orient='vertical', command = self.__dbGrid.yview)
		self.__verticalScrollBar.place(x = 1045, y = 5, height = 120)
		self.__dbGrid["columns"]=("begin_date", "end_date", "schedule", "location", "status")
		self.__dbGrid.column("#0", width = 100)
		self.__dbGrid.heading("#0", text = "Comisión")
		self.__dbGrid.column("#1", width = 120)
		self.__dbGrid.heading("#1", text = "Fecha Inicio")
		self.__dbGrid.column("#2", width = 120)
		self.__dbGrid.heading("#2", text = "Fecha Fin")
		self.__dbGrid.column("#3", width = 250)
		self.__dbGrid.heading("#3", text = "Horarios")
		self.__dbGrid.column("#4", width = 250)
		self.__dbGrid.heading("#4", text = "Locación")
		self.__dbGrid.column("#5", width = 200)
		self.__dbGrid.heading("#5", text = "Estado")
