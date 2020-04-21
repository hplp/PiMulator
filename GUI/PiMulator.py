#!/usr/bin/env python3

from tkinter import *
# from tkinter import messagebox
# import Pmw
# import os.path
# import shutil
# from subprocess import Popen, PIPE

## MAIN FRAME ##
class PiMulatorGUI(Frame):
    def __init__(self, master):
        self.parent_frame = master

        ## GUI Geography ##
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

        ## Linking GUI Geography and Regions ##
        # .:: creating the System Layer frame
        self.system_frame = SystemFrame(self.left_frame)

        # .:: creating the Logic Layer frame
        self.logic_frame = LogicFrame(self.left_frame)

        # .:: creating the Hardware Layer frame
        self.hardware_frame = HardwareFrame(self.left_frame)

        # .:: creating the Action frame
        self.action_frame = ActionFrame(self.rbot_frame)

## GUI Regions ##
class SystemFrame(Frame):
    def __init__(self, parent_frame):

        # System Frame Label
        Frame.__init__(self, parent_frame, borderwidth=1, relief=RAISED)
        self.pack(side=TOP, expand=YES, padx=2, pady=2, ipadx=2, ipady=2, fill=BOTH)
        Label(self, text="System Layer", font="TkDefaultFont 11 italic bold").grid(row=0, column=0, sticky=W)

        # Application selection drop-down Option Menu
        Label(self, text="Application: ").grid(row=1, column=0, sticky=W)
        benchmark_choices = {'HopScotch Bandwidth', 'HopScotch Latency'}
        default_benchmark = StringVar(self)
        default_benchmark.set('HopScotch Bandwidth')
        OptionMenu(self, default_benchmark, *benchmark_choices).grid(row=1, column=1, sticky=W)
        
        # Browse another application
        self.newapp_btn = Button(self, text="Browse new application")
        self.newapp_btn.grid(row=1, column=2, sticky=W)

        # Radio button, app either standalone or linux mode
        self.app_mode = StringVar()
        self.app_mode.set("standalone")
        brmtlRB = Radiobutton(self, text="Standalone", variable=self.app_mode, value="standalone")
        brmtlRB.grid(row=2, column=1, sticky=W)
        linuxRB = Radiobutton(self, text="Linux App", variable=self.app_mode, value="linux")
        linuxRB.grid(row=2, column=2, sticky=W)


class LogicFrame(Frame):
    def __init__(self, parent_frame):

        # Logic Frame Label
        Frame.__init__(self, parent_frame, borderwidth=1, relief=RAISED)
        self.pack(side=TOP, expand=YES, padx=2, pady=2, ipadx=2, ipady=2, fill=BOTH)
        Label(self, text="Logic Layer", font="TkDefaultFont 11 italic bold").grid(row=0, column=0, sticky=W)

        # CPU architecture selection drop-down Option Menu
        Label(self, text="CPU Architecture: ").grid(row=1, column=0, sticky=W)
        cpu_choices = {'U500-rocket', 'Ariane', 'MicroBlaze', 'Zynq'}
        default_cpu = StringVar(self)
        default_cpu.set('MicroBlaze')
        OptionMenu(self, default_cpu, *cpu_choices).grid(row=1, column=1, sticky=W)

        # Memory
        Label(self, text="Memory: ").grid(row=2, column=0, sticky=W)
        DDR2 = IntVar()
        Checkbutton(self, text="DDR2", variable=DDR2).grid(row=2, column=1, sticky=W)
        DDR3 = IntVar()
        Checkbutton(self, text="DDR3", variable=DDR3).grid(row=2, column=2, sticky=W)
        DDR4 = IntVar()
        Checkbutton(self, text="DDR4", variable=DDR4).grid(row=2, column=3, sticky=W)
        GDDR5 = IntVar()
        Checkbutton(self, text="GDDR5", variable=GDDR5).grid(row=2, column=4, sticky=W)
        GDDR5X = IntVar()
        Checkbutton(self, text="GDDR5X", variable=GDDR5X).grid(row=2, column=5, sticky=W)
        LPDDR3 = IntVar()
        Checkbutton(self, text="LPDDR3", variable=LPDDR3).grid(row=3, column=1, sticky=W)
        LPDDR4 = IntVar()
        Checkbutton(self, text="LPDDR4", variable=LPDDR4).grid(row=3, column=2, sticky=W)
        HMC = IntVar()
        Checkbutton(self, text="HMC", variable=HMC).grid(row=3, column=3, sticky=W)
        HBM = IntVar()
        Checkbutton(self, text="HBM", variable=HBM).grid(row=3, column=4, sticky=W)
        HBM2 = IntVar()
        Checkbutton(self, text="HBM2", variable=HBM2).grid(row=3, column=5, sticky=W)

        # Processing in Memory Topology
        Label(self, text="PiM Topology: ").grid(row=4, column=0, sticky=W)

class HardwareFrame(Frame):
    def __init__(self, parent_frame):

        Frame.__init__(self, parent_frame, borderwidth=1, relief=RAISED)
        self.pack(side=TOP, expand=YES, padx=2, pady=2, ipadx=2, ipady=2, fill=BOTH)
        Label(self, text="Hardware Layer", font="TkDefaultFont 11 italic bold").grid(row=0, sticky=W)

        # FPGA Board selection drop-down Option Menu
        Label(self, text="Hardware Platform: ").grid(row=1, column=0, sticky=W)
        platform_choices = {'Xilinx VC707 Evaluation Platform', 'Xilinx UltraZed-EG PCIe Card', 'Xilinx Alveo U280 Acceleration Card'}
        default_platform = StringVar(self)
        default_platform.set('Xilinx Alveo U280 Acceleration Card')
        OptionMenu(self, default_platform, *platform_choices).grid(row=1, column=1, sticky=W)

class ActionFrame(Frame):
    def __init__(self, parent_frame):

        Frame.__init__(self, parent_frame, borderwidth=1, relief=RAISED)
        self.pack(side=TOP, expand=YES, padx=2, pady=2, ipadx=2, ipady=2, fill=BOTH)
        Label(self, text="Actions", font="TkDefaultFont 11 italic bold").grid(row=0, sticky=W)

        # Final button
        Button(self, text="Generate SoC config", command=self.PiM_run).grid(row=1, sticky=W)
    def PiM_run(self):
        print("Starting PiMulator...")

window = Tk()
window.title("PiMulator")

window.geometry("%dx%d+0+0" % (0.8 * window.winfo_screenwidth(),
                               0.8 * window.winfo_screenheight()))
PiMulatorGUI(window)

window.mainloop()

print("Good bye!")

#         # message frame
#         self.message_frame = Frame(
#             self.parent_frame, borderwidth=5, relief=RIDGE)
#         self.message_frame.pack(side=TOP, expand=NO,
#                                 padx=10, pady=5, ipadx=5, ipady=5, fill=BOTH)
#         self.message_bar = Frame(self.message_frame)
#         self.message_bar.pack(side=LEFT, fill=BOTH, expand=YES)
#         self.message_buttons = Frame(self.message_frame, width=50)
#         self.message_buttons.pack(side=RIGHT, expand=NO, fill=X)