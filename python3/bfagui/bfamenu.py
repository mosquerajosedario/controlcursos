import tkinter as tk

class CustomMenu(tk.Menu):
	def __init__(self, master):
		tk.Menu.__init__(self, master)
		
		self.fileMenu = tk.Menu(self, tearoff = 0)
		self.fileMenu.add_command(label = "Salir", command = self.closeWindow)
		self.add_cascade(label = "Archivo", menu = self.fileMenu)
	
	def closeWindow(self):
		if isinstance(self.master, tk.Frame):
			quit()
		else:
			self.master.destroy()
