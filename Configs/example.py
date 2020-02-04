import m5
from m5.objects import *

m5.util.addToPath('learning_gem5/part1/')

#from caches import *


'''
    Setting up the System
'''

system = System()
system.clk_domain = SrcClockDomain()
system.clk_domain.clock = '2GHz'
system.clk_domain.voltage_domain = VoltageDomain()

system.mem_mode = 'timing'
system.mem_ranges = [AddrRange('1GB')]

system.cpu = TimingSimpleCPU()
system.membus = SystemXBar()

system.cpu.icache = L1ICache()
system.cpu.dcache = L1DCache()

system.cpu.icache.connectCPU(system.cpu)
system.cpu.dcache.connectCPU(system.cpu)

system.l2bus = L2XBar()

system.cpu.icache.connectBus(system.l2bus)
system.cpu.dcache.connectBus(system.l2bus)

system.l2cache = L2Cache()
system.l2cache.connectCPUSideBus(system.l2bus)
system.l2cache.connectMemSideBus(system.membus)

system.mem_ctrl = DDR4_2400_8x8()
system.mem_ctrl.range = system.mem_ranges[0]
system.mem_ctrl.port = system.membus.master

system.cpu.createInterruptController()
system.system_port = system.membus.slave



'''
    Setting up the simulation for Syscall Emulation Mode
'''

process = Process()
process.cmd = ['/home/tjt7a/gem5_binaries/bin/fib','10']
system.cpu.workload = process
system.cpu.createThreads()

root = Root(full_system=False, system=system)
m5.instantiate()

print("Begin Simulation")
exit_event = m5.simulate()

print("Exiting @ tick {} because {}".format(m5.curTick(), exit_event.getCause()))
