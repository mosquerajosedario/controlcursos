import tkinter as tk
from bfagui import bfamenu
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
	def __init__(self, master, title = "BFA", geometry = "400x200", icon = str(os.path.dirname(__file__)) + "/img/bfa.png", dbDriver = None):
		tk.Frame.__init__(self, master)
		self.master.title(title)
		self.master.geometry(geometry)
		image = tk.PhotoImage(file = icon)
		self.master.tk.call('wm', 'iconphoto', self.master._w, image)
		
		self.mainMenu = bfamenu.CustomMenu(self)
		self.master.config(menu = self.mainMenu)

class CustomForm(tk.Toplevel):
	def __init__(self, master, title = "BFA", geometry = "400x200", icon = str(os.path.dirname(__file__)) + "/img/bfa.png"):
		tk.Toplevel.__init__(self, master)
		self.title(title)
		self.geometry(geometry)
		image = tk.PhotoImage(file = icon)
		self.tk.call('wm', 'iconphoto', self._w, image)
		
		self.mainMenu = bfamenu.CustomMenu(self)
		self.config(menu = self.mainMenu)
