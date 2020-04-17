#!/usr/bin/env python3

from tkinter import *
#from tkinter import messagebox
# import Pmw
# import os.path
# import shutil
# from subprocess import Popen, PIPE


# class CpuFrame(Frame):

#     def __init__(self, top_frame, main_frame):

#         Frame.__init__(self, top_frame, width=50, borderwidth=2, relief=RIDGE)
#         self.pack(side=LEFT, expand=NO, fill=Y)
#         Label(self, text="CPU Architecture: ",
#               font="TkDefaultFont 11 bold").pack(side=TOP)

#         general_config_frame = Frame(self)
#         general_config_frame.pack(side=TOP)

#         cpu_choices = ["U500-rocket", "Ariane", "MicroBlaze", "Zynq"]

#         Label(general_config_frame, text="Core: ").grid(row=1, column=1)
#         Pmw.OptionMenu(general_config_frame, menubutton_font="TkDefaultFont 12",
#                        items=cpu_choices).grid(row=1, column=2)


# class MemoryFrame(Frame):

#     def __init__(self, top_frame, main_frame):

#         Frame.__init__(self, top_frame, width=50, borderwidth=2, relief=RIDGE)
#         self.pack(side=LEFT, expand=NO, fill=Y)
#         Label(self, text="Main Memory: ",
#               font="TkDefaultFont 11 bold").pack(side=TOP)

#         general_config_frame = Frame(self)
#         general_config_frame.pack(side=TOP)

#         memory_choices = ["DDR2", "DDR3", "DDR4", "GDDR5",
#                           "GDDR5X", "LPDDR3", "LPDDR4", "HMC", "HBM", "HBM2"]

#         Label(general_config_frame, text="Memory: ").grid(row=1, column=1)
#         Pmw.OptionMenu(general_config_frame, menubutton_font="TkDefaultFont 12",
#                        items=memory_choices).grid(row=1, column=2)


# class PlatformFrame(Frame):

#     def __init__(self, top_frame, main_frame):

#         Frame.__init__(self, top_frame, width=50, borderwidth=2, relief=RIDGE)
#         self.pack(side=LEFT, expand=NO, fill=Y)
#         Label(self, text="Hardware Platform: ",
#               font="TkDefaultFont 11 bold").pack(side=TOP)

#         general_config_frame = Frame(self)
#         general_config_frame.pack(side=TOP)

#         platform_choices = ["Xilinx VC707 Evaluation Platform",
#                             "Xilinx UltraZed-EG PCIe Card", "Xilinx Alveo U280 Acceleration Card"]

#         Label(general_config_frame, text="Platform: ").grid(row=1, column=1)
#         Pmw.OptionMenu(general_config_frame, menubutton_font="TkDefaultFont 12",
#                        items=platform_choices).grid(row=1, column=2)

## MAIN FRAME ##
class PiMulatorGUI(Frame):
    def __init__(self, master):
        self.parent_frame = master

        # left frame (System + Logic + Hardware Layers)
        self.left_frame = Frame(self.parent_frame, borderwidth=1, relief=SUNKEN)
        self.left_frame.pack(side=LEFT, expand=YES, padx=4, pady=4, ipadx=4, ipady=4, fill=BOTH)

        # right frame (includes right-top and right-bottom frames)
        self.right_frame = Frame(self.parent_frame)
        self.right_frame.pack(side=RIGHT, expand=YES, fill=BOTH)

        # right-top frame
        self.rtop_frame = Frame(self.right_frame, borderwidth=1, relief=SUNKEN)
        self.rtop_frame.pack(side=TOP, expand=YES, padx=4, pady=4, ipadx=4, ipady=4, fill=BOTH)

        # right-bottom frame
        self.rbot_frame = Frame(self.right_frame, borderwidth=1, relief=SUNKEN)
        self.rbot_frame.pack(side=BOTTOM, expand=YES, padx=4, pady=4, ipadx=4, ipady=4, fill=BOTH)

#         # message frame
#         self.message_frame = Frame(
#             self.parent_frame, borderwidth=5, relief=RIDGE)
#         self.message_frame.pack(side=TOP, expand=NO,
#                                 padx=10, pady=5, ipadx=5, ipady=5, fill=BOTH)
#         self.message_bar = Frame(self.message_frame)
#         self.message_bar.pack(side=LEFT, fill=BOTH, expand=YES)
#         self.message_buttons = Frame(self.message_frame, width=50)
#         self.message_buttons.pack(side=RIGHT, expand=NO, fill=X)

#         # final button
#         self.done = Button(
#             self.message_buttons, text="Generate SoC config", width=15,  command=self.PiM_run)
#         self.done.pack()

#         # .:: creating the configuration frame (read-only)
#         #cfg_frame = ConfigFrame(self.top_frame)

#         # .:: creating the selection frame

#         #self.select_frame = OptionFrame(self.top_frame)
#         # .:: creating the cache frame
#         #self.cache_frame = CacheFrame(self.top_frame, self)

##########################################
##########################################

        # .:: creating the System Layer frame
        self.system_frame = SystemFrame(self.left_frame)

        # .:: creating the Logic Layer frame
        self.logic_frame = LogicFrame(self.left_frame)

        # .:: creating the Hardware Layer frame
        self.hardware_frame = HardwareFrame(self.left_frame)

#         # .:: creating the CPU frame


#         self.cpu_frame = CpuFrame(self.top_frame, self)
#         self.memory_frame = MemoryFrame(self.top_frame, self)
#         self.platform_frame = PlatformFrame(self.top_frame, self)

#     def PiM_run(self):
#         print("Starting PiMulator...")

class SystemFrame(Frame):
    def __init__(self, parent_frame):

        # System Frame Label
        Frame.__init__(self, parent_frame, borderwidth=1, relief=RAISED)
        self.pack(side=TOP, expand=YES, padx=2, pady=2, ipadx=2, ipady=2, fill=BOTH)
        Label(self, text="System Layer", font="TkDefaultFont 11 italic bold").grid(row=0, column=0)

        # Application selection drop-down Option Menu
        Label(self, text="Application: ").grid(row=1, column=0)
        benchmark_choices = {'HopScotch Bandwidth', 'HopScotch Latency'}
        default_benchmark = StringVar(self)
        default_benchmark.set('HopScotch Bandwidth')
        OptionMenu(self, default_benchmark, *benchmark_choices).grid(row=1, column=1)
        
        # Browse another application
        self.newapp_btn = Button(self, text="Browse new application")
        self.newapp_btn.grid(row=1, column=2)

        # Radio button, app either standalone or linux mode
        self.app_mode = StringVar()
        self.app_mode.set("standalone")
        brmtlRB = Radiobutton(self, text="Standalone", variable=self.app_mode, value="standalone")
        brmtlRB.grid(row=2, column=1)
        linuxRB = Radiobutton(self, text="Linux App", variable=self.app_mode, value="linux")
        linuxRB.grid(row=2, column=2)


class LogicFrame(Frame):
    def __init__(self, parent_frame):

        Frame.__init__(self, parent_frame, borderwidth=1, relief=RAISED)
        self.pack(side=TOP, expand=YES, padx=2, pady=2, ipadx=2, ipady=2, fill=BOTH)
        Label(self, text="Logic Layer", font="TkDefaultFont 11 italic bold").grid(row=0)

        Label(self, text="CPU: ").grid(row=1, column=1)
        benchmark_choices = {'HopScotch Bandwidth', 'HopScotch Latency'}
        default_benchmark = StringVar(self)
        default_benchmark.set('HopScotch Bandwidth')
        OptionMenu(self, default_benchmark, *benchmark_choices).grid(row=1, column=2)


class HardwareFrame(Frame):
    def __init__(self, parent_frame):

        Frame.__init__(self, parent_frame, borderwidth=1, relief=RAISED)
        self.pack(side=TOP, expand=YES, padx=2, pady=2, ipadx=2, ipady=2, fill=BOTH)
        Label(self, text="Hardware Layer", font="TkDefaultFont 11 italic bold").grid(row=0)

        Label(self, text="CPU: ").grid(row=1, column=1)
        benchmark_choices = {'HopScotch Bandwidth', 'HopScotch Latency'}
        default_benchmark = StringVar(self)
        default_benchmark.set('HopScotch Bandwidth')
        OptionMenu(self, default_benchmark, *benchmark_choices).grid(row=1, column=2)


window = Tk()
window.title("PiMulator")

window.geometry("%dx%d+0+0" % (0.8 * window.winfo_screenwidth(),
                               0.8 * window.winfo_screenheight()))
PiMulatorGUI(window)

window.mainloop()

print("Good bye!")
