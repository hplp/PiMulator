#!/usr/bin/env python3

import tkinter as tk

class Application(tk.Frame):
    def __init__(self, master=None):
        super().__init__(master)
        self.master = master
        self.pack()
        self.create_widgets()

    def create_widgets(self):
        # self.Frame1 = tk.Frame(self, width=200, height=150, background="Blue")
        # self.Frame1.grid(row=0, column=0)

        # frame2=Frame(master, width=200, height=150, background="Red")
        # frame2.grid(row=1, column=0)

        # frame3=Frame(master, width=200, height=150, background="Green")
        # frame3.grid(row=0, column=1)

        # frame4=Frame(master, width=200, height=150, background="Yellow")
        # frame4.grid(row=1, column=1)
        self.Button_run = tk.Button(self)
        self.Button_run["text"] = "Run"
        self.Button_run["command"] = self.PiM_run
        self.Button_run.pack(side="top")

        self.quit = tk.Button(self, text="QUIT", fg="red", command=self.master.destroy)
        self.quit.pack(side="bottom")

    def PiM_run(self):
        print("Starting PiMulator...")

root = tk.Tk()
root.geometry("1120x840")
root.title("PiMulator")
app = Application(master=root)
app.mainloop()

print("Good bye!")