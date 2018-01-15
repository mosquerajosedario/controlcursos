import tkinter as tk

class CancelButton(tk.Button):
	def __init__(self, master):
		tk.Button.__init__(self, master, text = "Cancelar", command = self.closeWindow)
	
	def closeWindow(self):
		if isinstance(self.master, tk.Frame):
			quit()
		else:
			self.master.destroy()
	
	def getWidth(self):
		return 80

class AddButton(tk.Button):
	def __init__(self, master):
		tk.Button.__init__(self, master, text = "Agregar")

class UpdateButton(tk.Button):
	def __init__(self, master):
		tk.Button.__init__(self, master, text = "Actualizar")
