import tkinter as tk
from tkinter import messagebox as mb
from tkinter import ttk
from bfagui import bfaform
from bfagui import bfabutton
import json

class LocationMainForm(bfaform.CustomForm):
	def __init__(self, master, pgConnection):
		self.pgConnection = pgConnection
		
		bfaform.CustomForm.__init__(self, master, "Administración de Locaciones", "690x130", "./img/locacion.png")
		
		self.dbGrid = ttk.Treeview(self, height = 5)
		self.dbGrid.place(x = 5, y = 5)
		self.verticalScrollBar = ttk.Scrollbar(self, orient='vertical', command = self.dbGrid.yview)
		self.verticalScrollBar.place(x = 670, y = 5, height = 120)
		self.dbGrid["columns"]=("name", "address", "phone", "email")
		self.dbGrid.column("#0", width = 50)
		self.dbGrid.heading("#0", text = "ID")
		self.dbGrid.column("#1", width = 120)
		self.dbGrid.heading("#1", text = "Nombre")
		self.dbGrid.column("#2", width = 200)
		self.dbGrid.heading("#2", text = "Dirección")
		self.dbGrid.column("#3", width = 100)
		self.dbGrid.heading("#3", text = "Teléfono")
		self.dbGrid.column("#4", width = 200)
		self.dbGrid.heading("#4", text = "Correo Electrónico")
		self.dbGrid.bind("<Double-1>", self.onDoubleClick)
		
		self.locationMenu = tk.Menu(self.mainMenu, tearoff = 0)
		self.locationMenu.add_command(label = "Alta de locación", command = self.addLocation)
		self.locationMenu.add_command(label = "Modificar locación")
		self.locationMenu.add_separator()
		self.locationMenu.add_command(label = "Baja de locación")
		
		self.mainMenu.add_cascade(label = "Locaciones", menu = self.locationMenu)
		
		self.updateGrid()
	
	def onDoubleClick(self, event):
		item = self.dbGrid.selection()
		
		if item != ():
			selectedLocation = self.dbGrid.set(item)
			selectedLocation["location_id"] = self.dbGrid.item(item,"text")
			
			self.updateLocation(selectedLocation)
	
	def updateLocation(self, selectedLocation):
		updateLocationForm = EditLocationForm(self, self.pgConnection, operation = "update")
		updateLocationForm.idText.set(selectedLocation["location_id"])
		updateLocationForm.nameText.set(selectedLocation["name"])
		updateLocationForm.addressText.set(selectedLocation["address"])
		updateLocationForm.phoneText.set(selectedLocation["phone"])
		updateLocationForm.emailText.set(selectedLocation["email"])
		self.wait_window(updateLocationForm)
		self.updateGrid()

	def addLocation(self):
		editLocationForm = EditLocationForm(self, self.pgConnection, operation = "add")
		self.wait_window(editLocationForm)
		self.updateGrid()
		
	def updateGrid(self):
		locations = self.pgConnection.queryJson("SELECT location_gui_list_locations()")
		
		self.dbGrid.delete(*self.dbGrid.get_children())
	
		for location in locations:
			self.dbGrid.insert('', 'end', text = location["location_id"], values=(location["name"], \
			  location["address"], location["phone"], location["email"]))


class EditLocationForm(bfaform.CustomForm):
	def __init__(self, master, pgConnection, operation):
		self.pgConnection = pgConnection
		
		yNext = lambda y : y + 20
		yNextNext = lambda y : y + 30
		
		yValue = 10
		
		bfaform.CustomForm.__init__(self, master, "Administración de Locaciones", "270x300", "./img/locacion.png")
		
		self.idLabel = tk.Label(self, text = "ID:")
		self.idLabel.place (x = 10, y = yValue)
		yValue = yNext(yValue)
		self.idText = tk.StringVar()
		self.idEntry = tk.Entry(self, width = 5, state = "disabled", textvariable = self.idText)
		self.idEntry.place(x = 10, y = yValue)
		
		yValue = yNextNext(yValue)
		self.nameLabel = tk.Label(self, text = "Nombre:")
		self.nameLabel.place(x = 10, y = yValue)
		yValue = yNext(yValue)
		self.nameText = tk.StringVar()
		self.nameEntry = tk.Entry(self, width = 30, textvariable = self.nameText)
		self.nameEntry.place(x = 10, y = 80)
		
		yValue = yNextNext(yValue)
		self.addressLabel = tk.Label(self, text = "Dirección:")
		self.addressLabel.place(x = 10, y = yValue)
		yValue = yNext(yValue)
		self.addressText = tk.StringVar()
		self.addressEntry = tk.Entry(self, width = 30, textvariable = self.addressText)
		self.addressEntry.place(x = 10, y = yValue)
		
		yValue = yNextNext(yValue)
		self.phoneLabel = tk.Label(self, text = "Teléfono:")
		self.phoneLabel.place(x = 10, y = yValue)
		yValue = yNext(yValue)
		self.phoneText = tk.StringVar()
		self.phoneEntry = tk.Entry(self, width = 30, textvariable = self.phoneText)
		self.phoneEntry.place(x = 10, y = yValue)
		
		yValue = yNextNext(yValue)
		self.emailLabel = tk.Label(self, text = "Correo Electrónico:")
		self.emailLabel.place(x = 10, y = yValue)
		yValue = yNext(yValue)
		self.emailText = tk.StringVar()
		self.emailEntry = tk.Entry(self, width = 30, textvariable = self.emailText)
		self.emailEntry.place(x = 10, y = yValue)
		
		yValue = yNextNext(yValue)
		if operation == "add":
			self.actionButton = bfabutton.AddButton(self)
			self.actionButton.place(x = 10, y = yValue)
			self.actionButton.config(command = self.addLocation)
			self.title("Alta de Locaciones")
		elif operation == "update":
			self.actionButton = bfabutton.UpdateButton(self)
			self.actionButton.place(x = 10, y = yValue)
			self.actionButton.config(command = self.updateLocation)
			self.title("Modificación de Locaciones")
		
		self.cancelButton = bfabutton.CancelButton(self)
		self.cancelButton.place(x = 174, y = yValue)
		
		self.nameEntry.focus_set()
	
	def addLocation(self):
		location = {}
		location["name"] = self.nameEntry.get()
		location["address"] = self.addressEntry.get()
		location["phone"] = self.phoneEntry.get()
		location["email"] = self.emailEntry.get()
		
		location_json = json.dumps(location , ensure_ascii=False)
		
		queryString = "SELECT location_gui_add_location('" + location_json + "')"
		
		try:
			result = self.pgConnection.queryJson(queryString)
			mb.showinfo("Alta exitosa", "Nueva locación agregada ID: " + str(result["location_id"]))
			self.destroy()
		except:
			mb.showerror("ERROR", "ERROR AL EJECUTAR LA CONSULTA")
			self.destroy()
	
	def updateLocation(self):
		location = {}
		location["location_id"] = int(self.idEntry.get())
		location["name"] = self.nameEntry.get()
		location["address"] = self.addressEntry.get()
		location["phone"] = self.phoneEntry.get()
		location["email"] = self.emailEntry.get()
		
		location_json = json.dumps(location , ensure_ascii=False)
		
		queryString = "SELECT location_gui_update_location('" + location_json + "')"
		
		try:
			self.pgConnection.execute(queryString)
			mb.showinfo("Actualización de Locación", "Actualización de Locación exitosa")
			self.destroy()
		except:
			mb.showerror("ERROR", "ERROR AL EJECUTAR LA CONSULTA")
			self.destroy()
