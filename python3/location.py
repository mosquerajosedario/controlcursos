import tkinter as tk
from tkinter import messagebox as mb
from tkinter import simpledialog as sd
from tkinter import ttk
from bfagui import bfaform
from bfagui import bfabutton
import json

class LocationMainForm(bfaform.CustomForm):
	def __init__(self, master, pgConnection, behavior = "main"):
		self.__behavior = behavior
		self.__pgConnection = pgConnection
		
		bfaform.CustomForm.__init__(self, master, "Administración de Locaciones", "1140x130", "./img/locacion.png")
		
		self.__dbGrid = ttk.Treeview(self, height = 5)
		self.__dbGrid.place(x = 5, y = 5)
		self.__verticalScrollBar = ttk.Scrollbar(self, orient='vertical', command = self.__dbGrid.yview)
		self.__verticalScrollBar.place(x = 1120, y = 5, height = 120)
		self.__dbGrid["columns"]=("name", "address", "phone", "email", "status")
		self.__dbGrid.column("#0", width = 50)
		self.__dbGrid.heading("#0", text = "ID")
		self.__dbGrid.column("#1", width = 250)
		self.__dbGrid.heading("#1", text = "Nombre")
		self.__dbGrid.column("#2", width = 300)
		self.__dbGrid.heading("#2", text = "Dirección")
		self.__dbGrid.column("#3", width = 150)
		self.__dbGrid.heading("#3", text = "Teléfono")
		self.__dbGrid.column("#4", width = 250)
		self.__dbGrid.heading("#4", text = "Correo Electrónico")
		self.__dbGrid.column("#5", width = 120)
		self.__dbGrid.heading("#5", text = "Estado")
		self.__dbGrid.bind("<Double-1>", self.onDoubleClick)
		
		self.__locationMenu = tk.Menu(self._mainMenu, tearoff = 0)
		self.__locationMenu.add_command(label = "Alta de locación", command = self.addLocation)
		self.__locationMenu.add_command(label = "Modificar locación", command = \
		  lambda: mb.showinfo("Modificar Locación", "Doble Click sobre la locación que desea modificar..."))
		self.__locationMenu.add_separator()
		self.__locationMenu.add_command(label = "Baja de locación", command = self.destroyLocation)
		
		self._mainMenu.add_cascade(label = "Locaciones", menu = self.__locationMenu)
		
		if self.__behavior == "search":
			self._mainMenu.destroy()
			self.__selectedLocation = tk.StringVar()
		
		self.updateGrid()
	
	def destroyLocation(self):
		location = {}
		location["location_id"] = sd.askinteger("Eliminando Locación...", "Ingrese el ID de locacion a eliminar:")
		
		if location["location_id"] != None:
			try:
				queryString = "SELECT location_gui_destroy_location('" + json.dumps(location) + "')"
				self.__pgConnection.execute(queryString)
				
				mb.showinfo("Eliminando Locación...", "Eliminación de locación exitosa")
				self.updateGrid()
			except ValueError as e:
				mb.showerror("ERROR", "ERROR AL EJECUTAR LA CONSULTA: " + format(e))
		else:
				mb.showerror("ERROR", "NO SE INGRESÓ NINGUN VALOR...")
	
	def get_selectedLocation(self):
		try:
			return self.__selectedLocation.get()
		except:
			return None
	
	def onDoubleClick(self, event):
		item = self.__dbGrid.selection()
		
		if item != ():
			selectedLocation = self.__dbGrid.set(item)
			selectedLocation["location_id"] = self.__dbGrid.item(item,"text")
			
			if self.__behavior == "main":
				self.updateLocation(selectedLocation)
			elif self.__behavior == "search":
				self.__selectedLocation.set(selectedLocation)
				self.destroy()
	
	def updateLocation(self, selectedLocation):
		updateLocationForm = EditLocationForm(self, self.__pgConnection, operation = "update")
		updateLocationForm.set_idText(selectedLocation["location_id"])
		updateLocationForm.set_nameText(selectedLocation["name"])
		updateLocationForm.set_addressText(selectedLocation["address"])
		updateLocationForm.set_phoneText(selectedLocation["phone"])
		updateLocationForm.set_emailText(selectedLocation["email"])
		updateLocationForm.set_statusText(selectedLocation["status"])
		self.wait_window(updateLocationForm)
		self.updateGrid()

	def addLocation(self):
		editLocationForm = EditLocationForm(self, self.__pgConnection, operation = "add")
		self.wait_window(editLocationForm)
		self.updateGrid()
		
	def updateGrid(self):
		if self.__behavior == "main":
			locations = self.__pgConnection.queryJson("SELECT location_gui_list_all_locations()")
		elif self.__behavior == "search":
			locations = self.__pgConnection.queryJson("SELECT location_gui_list_enabled_locations()")
		
		self.__dbGrid.delete(*self.__dbGrid.get_children())
		
		if locations != None:
			for location in locations:
				self.__dbGrid.insert('', 'end', text = location["location_id"], values=(location["name"], \
				  location["address"], location["phone"], location["email"], location["status"]))


class EditLocationForm(bfaform.CustomForm):
	def __init__(self, master, pgConnection, operation):
		self.__pgConnection = pgConnection
		
		yNext = lambda y : y + 20
		yNextNext = lambda y : y + 30
		
		yValue = 10
		
		bfaform.CustomForm.__init__(self, master, "Administración de Locaciones", "270x370", "./img/locacion.png")
		
		self.__idLabel = tk.Label(self, text = "ID:")
		self.__idLabel.place (x = 10, y = yValue)
		yValue = yNext(yValue)
		self.__idText = tk.StringVar()
		self.__idEntry = tk.Entry(self, width = 5, state = "disabled", textvariable = self.__idText)
		self.__idEntry.place(x = 10, y = yValue)
		
		yValue = yNextNext(yValue)
		self.__nameLabel = tk.Label(self, text = "Nombre:")
		self.__nameLabel.place(x = 10, y = yValue)
		yValue = yNext(yValue)
		self.__nameText = tk.StringVar()
		self.__nameEntry = tk.Entry(self, width = 30, textvariable = self.__nameText)
		self.__nameEntry.place(x = 10, y = 80)
		if operation == "update":
			self.__nameEntry.config(state = "disabled")
		
		yValue = yNextNext(yValue)
		self.__addressLabel = tk.Label(self, text = "Dirección:")
		self.__addressLabel.place(x = 10, y = yValue)
		yValue = yNext(yValue)
		self.__addressText = tk.StringVar()
		self.__addressEntry = tk.Entry(self, width = 30, textvariable = self.__addressText)
		self.__addressEntry.place(x = 10, y = yValue)
		
		yValue = yNextNext(yValue)
		self.__phoneLabel = tk.Label(self, text = "Teléfono:")
		self.__phoneLabel.place(x = 10, y = yValue)
		yValue = yNext(yValue)
		self.__phoneText = tk.StringVar()
		self.__phoneEntry = tk.Entry(self, width = 30, textvariable = self.__phoneText)
		self.__phoneEntry.place(x = 10, y = yValue)
		
		yValue = yNextNext(yValue)
		self.__emailLabel = tk.Label(self, text = "Correo Electrónico:")
		self.__emailLabel.place(x = 10, y = yValue)
		yValue = yNext(yValue)
		self.__emailText = tk.StringVar()
		self.__emailEntry = tk.Entry(self, width = 30, textvariable = self.__emailText)
		self.__emailEntry.place(x = 10, y = yValue)
		
		yValue = yNextNext(yValue)
		self.__statusLabel = tk.Label(self, text = "Estado:")
		self.__statusLabel.place(x = 10, y = yValue)
		yValue = yNext(yValue)
		self.__statusText = tk.StringVar()
		self.__statusText.set("HABILITADO")
		self.__statusOptionMenu = tk.OptionMenu(self, self.__statusText, "HABILITADO", "DESHABILITADO")
		self.__statusOptionMenu.place(x = 10, y = yValue)
		if operation == "add":
			self.__statusOptionMenu.config(state = "disabled")
			
		yValue = yNext(yValue)
		yValue = yNextNext(yValue)
		if operation == "add":
			self.__actionButton = bfabutton.AddButton(self)
			self.__actionButton.place(x = 10, y = yValue)
			self.__actionButton.config(command = self.addLocation)
			self.title("Alta de Locaciones")
		elif operation == "update":
			self.__actionButton = bfabutton.UpdateButton(self)
			self.__actionButton.place(x = 10, y = yValue)
			self.__actionButton.config(command = self.updateLocation)
			self.title("Modificación de Locaciones")
		
		self.__cancelButton = bfabutton.CancelButton(self)
		self.__cancelButton.place(x = 174, y = yValue)
		
		if operation == "add":
			self.__nameEntry.focus_set()
		elif operation == "update":
			self.__addressEntry.focus_set()
	
	def set_idText(self, idText):
		self.__idText.set(idText)
	
	def set_nameText(self, nameText):
		self.__nameText.set(nameText)
		
	def set_addressText(self, addressText):
		self.__addressText.set(addressText)
	
	def set_phoneText(self, phoneText):
		self.__phoneText.set(phoneText)
	
	def set_emailText(self, emailText):
		self.__emailText.set(emailText)
	
	def set_statusText(self, statusText):
		self.__statusText.set(statusText)
	
	def addLocation(self):
		location = {}
		location["name"] = self.__nameEntry.get()
		location["address"] = self.__addressEntry.get()
		location["phone"] = self.__phoneEntry.get()
		location["email"] = self.__emailEntry.get()
		location["status"] = self.__statusText.get()
		
		if location["name"] == "":
			mb.showerror("ERROR", "ERROR EN EL INGRESO DE DATOS. VERIFIQUE POR FAVOR...")
		else:
			location_json = json.dumps(location , ensure_ascii=False)
			
			queryString = "SELECT location_gui_add_location('" + location_json + "')"
			
			try:
				result = self.__pgConnection.queryJson(queryString)
				mb.showinfo("Alta exitosa", "Nueva locación agregada ID: " + str(result["location_id"]))
				self.destroy()
			except ValueError as e:
				mb.showerror("ERROR", "ERROR AL EJECUTAR LA CONSULTA: " + format(e))
				self.destroy()
	
	def updateLocation(self):
		location = {}
		location["location_id"] = int(self.__idEntry.get())
		location["name"] = self.__nameEntry.get()
		location["address"] = self.__addressEntry.get()
		location["phone"] = self.__phoneEntry.get()
		location["email"] = self.__emailEntry.get()
		location["status"] = self.__statusText.get()
		
		location_json = json.dumps(location , ensure_ascii=False)
		
		queryString = "SELECT location_gui_update_location('" + location_json + "')"
		
		try:
			self.__pgConnection.execute(queryString)
			mb.showinfo("Actualización de Locación", "Actualización de Locación exitosa")
			self.destroy()
		except ValueError as e:
			mb.showerror("ERROR", "ERROR AL EJECUTAR LA CONSULTA: " + format(e))
			self.destroy()
