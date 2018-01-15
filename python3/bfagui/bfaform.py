import tkinter as tk
from tkinter import ttk
from bfagui import bfamenu
from bfagui import bfabutton
import os

def centerForm(toplevel):
	toplevel.update_idletasks()
	
	width = toplevel.winfo_screenwidth()
	heigth = toplevel.winfo_screenheight()
	
	size = tuple(int(_) for _ in toplevel.geometry().split('+')[0].split('x'))
	
	x = width/2 - size[0]/2
	y = heigth/2 - size[1]/2
	
	toplevel.geometry("%dx%d+%d+%d" % (size + (x, y)))

def login():
	def getUserPassword():
		userPassword["userName"] = userEntry.get()
		userPassword["password"] = passwordEntry.get()
		
		loginForm.destroy()

	userPassword = {}
	
	loginForm = tk.Tk()
	loginForm.title("Inicio de Sesión")
	loginForm.geometry("300x150")
	image = tk.PhotoImage(file = str(os.path.dirname(__file__)) + "/img/login.png")
	loginForm.tk.call('wm', 'iconphoto', loginForm._w, image)
	centerForm(loginForm)
	
	userLabel = tk.Label(loginForm, text = "Usuario:")
	userLabel.place(x = 10, y = 10)
	userEntry = tk.Entry(loginForm, width = 34)
	userEntry.place(x = 10, y = 30)
	
	passwordLabel = tk.Label(loginForm, text = "Contraseña:")
	passwordLabel.place(x = 10, y = 60)
	passwordEntry = tk.Entry(loginForm, width = 34, show = "*")
	passwordEntry.place(x = 10, y = 80)
	
	acceptButton = tk.Button(loginForm, text = "Aceptar", command = getUserPassword)
	acceptButton.place(x = 10, y = 115)
	
	cancelButton = tk.Button(loginForm, text = "Cancelar", command = quit)
	cancelButton.place(x = 208, y= 115)
	
	userEntry.focus_set()
	
	loginForm.mainloop()
	
	return userPassword

class BaseForm(tk.Frame):
	def __init__(self, master, title = "BaseForm", geometry = "400x200", \
	  icon = str(os.path.dirname(__file__)) + "/img/bfa.png", dbDriver = None):
		tk.Frame.__init__(self, master)
		self.master.title(title)
		self.master.geometry(geometry)
		image = tk.PhotoImage(file = icon)
		self.master.tk.call('wm', 'iconphoto', self.master._w, image)
		
		self._mainMenu = bfamenu.CustomMenu(self)
		self.master.config(menu = self._mainMenu)
		centerForm(self.master)

class CustomForm(tk.Toplevel):
	def __init__(self, master, title = "CustomForm", geometry = "400x200", \
	  icon = str(os.path.dirname(__file__)) + "/img/bfa.png"):
		tk.Toplevel.__init__(self, master)
		self.title(title)
		self.geometry(geometry)
		image = tk.PhotoImage(file = icon)
		self.tk.call('wm', 'iconphoto', self._w, image)
		
		self._mainMenu = bfamenu.CustomMenu(self)
		self.config(menu = self._mainMenu)
		
		centerForm(self)

class GridForm(CustomForm):
	def __init__(self, master, pgConnection, setup, gridColumns, behavior = "main"):
		self._behavior = behavior
		self._pgConnection = pgConnection
		self._mainQuery = "SELECT " + setup["querys"]["mainQuery"]
		self._searchQuery = "SELECT " + setup["querys"]["searchQuery"]
		
		while setup["formHeight"] % 20 != 0:
			setup["formHeight"] += 1
		
		columnNames = []
		columnIDs = []
		formWidth = 25
		
		for key, value in gridColumns.items():
			columnNames.append(key)
			columnIDs.append(key)
			formWidth += value
		
		del columnIDs[0]
		
		formGeometry = str(formWidth) + "x" + str(setup["formHeight"])
		
		CustomForm.__init__(self, master, setup["title"], formGeometry, setup["icon"])
		
		gridHeight = int((setup["formHeight"] / 20) - 2)
		
		self._dbGrid = ttk.Treeview(self, height = gridHeight)
		self._dbGrid.place(x = 5, y = 5)
		verticalScrollBar = ttk.Scrollbar(self, orient='vertical', command = self._dbGrid.yview)
		verticalScrollBar.place(x = formWidth - 19, y = 5, height = setup["formHeight"] - 20)
		self._dbGrid["columns"] = columnIDs
		
		for i in range(len(columnNames)):
			columnID = "#" + str(i)
			columnWidth = gridColumns[columnNames[i]]
			
			self._dbGrid.column(columnID, width = columnWidth)
			self._dbGrid.heading(columnID, text = columnNames[i])
		
		if self._behavior == "search":
			self._mainMenu.destroy()
			self.__selectedItem = tk.StringVar()

		self.updateGrid()
	
	def getData(self):
		if self._behavior == "main":
			self._items = self._pgConnection.queryJson(self._mainQuery)
		elif self._behavior == "search":
			self._items = self._pgConnection.queryJson(self._searchQuery)
		
		self._dbGrid.delete(*self._dbGrid.get_children())
		
	def updateGrid(self):
		pass

class EditForm(CustomForm):
	def __init__(self, master, setup, fields, operation = "add"):
		if operation not in ["add", "update"]:
			raise ValueError("EditForm ERROR: El parámetro operation no es válido (add / update)")
		
		self.__operation = operation
		#self.__pgConnection = pgConnection
		
		yNext = lambda y : y + 20
		yNextNext = lambda y : y + 30
		
		yPosition = 10
		xPosition = 10 # CONSTANTE NO TOCAR!!
		totalEditHeight = 50 # CONSTANTE NO TOCAR!!
		buttonsHeight = 20 # CONSTANTE NO TOCAR!!
		marginHeight = 20 # CONSTANTE NO TOCAR!!
		
		formHeight = yPosition + len(fields) * totalEditHeight + buttonsHeight + marginHeight
		
		formWidth = -1
		for key, value in fields.items():
			if value * 10 > formWidth:
				formWidth = round(value * 8.2)
		formWidth +=20
		
		formGeometry = str(formWidth) + "x" + str(formHeight)
		
		CustomForm.__init__(self, master, setup["title"], formGeometry, setup["icon"])
		
		self._inputFields = []
		
		for key, value in fields.items():
			genericLabel = tk.Label(self, text = key + ":")
			genericLabel.place(x = xPosition, y = yPosition)
			yPosition = yNext(yPosition)
			
			entry = {}
			entry["name"] = key
			entry["StringVar"] = tk.StringVar()
			
			entry["Entry"] = tk.Entry(self, width = value, textvariable = entry["StringVar"])
			entry["Entry"].place(x = xPosition, y = yPosition)
			entry["EntryXY"] = [xPosition, yPosition]
			
			yPosition = yNextNext(yPosition)
			
			self._inputFields.append(entry)
		
		self._cancelButton = bfabutton.CancelButton(self)
		self._cancelButton.place(x = xPosition, y = yPosition)
		
		if self.__operation == "add":
			self._setButton = bfabutton.AddButton(self)
		else:
			self._setButton = bfabutton.UpdateButton(self)
		
		self._setButton.place(x = xPosition + self._cancelButton.getWidth() + 10, y = yPosition)
			
	def disableEntry(self, names):
		for name in names:
			for i in range(len(self._inputFields)):
				if self._inputFields[i]["name"] == name:
					self._inputFields[i]["Entry"].config(state = "disabled")
	
	def setFocus(self, name):
		for i in range(len(self._inputFields)):
			if self._inputFields[i]["name"] == name:
				self._inputFields[i]["Entry"].focus_set()
	
	def toDropDown(self, name, items, defaultValue):
		for inputIndex in range(len(self._inputFields)):
			if self._inputFields[inputIndex]["name"] == name:
				self._inputFields[inputIndex]["Entry"].destroy()
				self._inputFields[inputIndex]["StringVar"].set(defaultValue)
				self._inputFields[inputIndex]["Entry"] = tk.OptionMenu(self, \
				  self._inputFields[inputIndex]["StringVar"], *items)
				self._inputFields[inputIndex]["Entry"].place(x = self._inputFields[inputIndex]["EntryXY"][0], \
				  y = self._inputFields[inputIndex]["EntryXY"][1])
	
	def setEntryValue(self, name, value):
		for inputIndex in range(len(self._inputFields)):
			if self._inputFields[inputIndex]["name"] == name:
				self._inputFields[inputIndex]["StringVar"].set(value)
