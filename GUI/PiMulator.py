#!/usr/bin/env python3

from tkinter import *
from tkinter import messagebox
import Pmw
import os.path
import shutil
from subprocess import Popen, PIPE

class CpuFrame(Frame):

    def __init__(self, top_frame, main_frame):
        
        Frame.__init__(self, top_frame, width=50, borderwidth=2, relief=RIDGE)
        self.pack(side=LEFT, expand=NO, fill=Y)
        Label(self, text = "CPU Architecture: ", font="TkDefaultFont 11 bold").pack(side = TOP)

        general_config_frame = Frame(self)
        general_config_frame.pack(side=TOP)

        cpu_choices = ["U500-rocket", "Ariane", "MicroBlaze", "Zynq"]

        Label(general_config_frame, text = "Core: ").grid(row=1, column=1)
        Pmw.OptionMenu(general_config_frame, menubutton_font="TkDefaultFont 12",
                items=cpu_choices).grid(row=1,column=2)

class MemoryFrame(Frame):

    def __init__(self, top_frame, main_frame):
        
        Frame.__init__(self, top_frame, width=50, borderwidth=2, relief=RIDGE)
        self.pack(side=LEFT, expand=NO, fill=Y)
        Label(self, text = "Main Memory: ", font="TkDefaultFont 11 bold").pack(side = TOP)

        general_config_frame = Frame(self)
        general_config_frame.pack(side=TOP)

        memory_choices = ["DDR2", "DDR3", "DDR4", "GDDR5", "GDDR5X", "LPDDR3", "LPDDR4", "HMC", "HBM", "HBM2"]

        Label(general_config_frame, text = "Memory: ").grid(row=1, column=1)
        Pmw.OptionMenu(general_config_frame, menubutton_font="TkDefaultFont 12",
                items=memory_choices).grid(row=1,column=2)

class BenchmarkFrame(Frame):

    def __init__(self, top_frame, main_frame):
        
        Frame.__init__(self, top_frame, width=50, borderwidth=2, relief=RIDGE)
        self.pack(side=LEFT, expand=NO, fill=Y)
        Label(self, text = "Benchmark Application: ", font="TkDefaultFont 11 bold").pack(side = TOP)

        general_config_frame = Frame(self)
        general_config_frame.pack(side=TOP)

        benchmark_choices = ["HopScotch Bandwidth", "HopScotch Latency"]

        Label(general_config_frame, text = "Application: ").grid(row=1, column=1)
        Pmw.OptionMenu(general_config_frame, menubutton_font="TkDefaultFont 12",
                items=benchmark_choices).grid(row=1,column=2)

class PlatformFrame(Frame):

    def __init__(self, top_frame, main_frame):
        
        Frame.__init__(self, top_frame, width=50, borderwidth=2, relief=RIDGE)
        self.pack(side=LEFT, expand=NO, fill=Y)
        Label(self, text = "Hardware Platform: ", font="TkDefaultFont 11 bold").pack(side = TOP)

        general_config_frame = Frame(self)
        general_config_frame.pack(side=TOP)

        platform_choices = ["Xilinx VC707 Evaluation Platform", "Xilinx UltraZed-EG PCIe Card", "Xilinx Alveo U280 Acceleration Card"]

        Label(general_config_frame, text = "Platform: ").grid(row=1, column=1)
        Pmw.OptionMenu(general_config_frame, menubutton_font="TkDefaultFont 12",
                items=platform_choices).grid(row=1,column=2)

class PiMulator(Frame):
    def __init__(self, master):
        
        self.ParentFrame = master

        #..create the general layout
	
        #top frame
        self.top_frame = Frame(self.ParentFrame, borderwidth=5, relief=RIDGE)
        self.top_frame.pack(side=TOP,expand=NO,padx=10,pady=5,ipadx=5,ipady=5,fill=BOTH)
        
        #bottom frame
        self.bottom_frame = Frame(self.ParentFrame, borderwidth=5,relief=RIDGE)
        self.bottom_frame.pack(side=TOP,expand=YES,padx=10,pady=5,ipadx=5,ipady=5,fill=BOTH)

        #message frame
        self.message_frame = Frame(self.ParentFrame, borderwidth=5, relief=RIDGE)
        self.message_frame.pack(side=TOP, expand=NO,  padx=10, pady=5, ipadx=5, ipady=5, fill=BOTH)
        self.message_bar = Frame(self.message_frame)
        self.message_bar.pack(side=LEFT,fill=BOTH,expand=YES)
        self.message_buttons = Frame(self.message_frame, width=50)
        self.message_buttons.pack(side=RIGHT, expand=NO, fill=X)

        #final button
        self.done = Button(self.message_buttons, text="Generate SoC config", width=15,  command=self.PiM_run)
        self.done.pack()

        #.:: creating the configuration frame (read-only)
        #cfg_frame = ConfigFrame(self.top_frame)
        #.:: creating the selection frame
        #self.select_frame = OptionFrame(self.top_frame)
        #.:: creating the cache frame
        #self.cache_frame = CacheFrame(self.top_frame, self)
        #.:: creating the CPU frame
        self.benchmark_frame = BenchmarkFrame(self.top_frame, self)
        self.cpu_frame = CpuFrame(self.top_frame, self)
        self.memory_frame = MemoryFrame(self.top_frame, self)
        self.platform_frame = PlatformFrame(self.top_frame, self)
        



    def PiM_run(self):
        print("Starting PiMulator...")


root = Tk()
root.title("PiMulator")

root.geometry("1000x700")
w, h = root.winfo_screenwidth(), root.winfo_screenheight()
root.geometry("%dx%d+0+0" % (w, h))
app = PiMulator(root)

root.mainloop()

print("Good bye!")
