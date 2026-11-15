import m5
from m5.objects import *
import argparse

# Command-line argument parser
parser = argparse.ArgumentParser(description="gem5 ILP Simulation Driver")
parser.add_argument("--cpu_type", type=str, default="o3", help="cpu type: timing, minor, or o3")
parser.add_argument("--width", type=int, default=4, help="fetch/decode/issue width for O3CPU")
parser.add_argument("--bp_type", type=str, default="TournamentBP", help="branch predictor type: LocalBP, TournamentBP, BiModeBP")
parser.add_argument("--cmd", type=str, default="./stride_output", help="binary workload executable")
parser.add_argument("--options", type=str, default="1", help="workload arguments (stride)")
args = parser.parse_args()

# System and Clock Domain Setup
system = System()
system.clk_domain = SrcClockDomain(clock="1GHz", voltage_domain=VoltageDomain())
system.mem_mode = "timing"
system.mem_ranges = [AddrRange("512MiB")]

# CPU Model Selection & Parameterization
if args.cpu_type == "timing":
    system.cpu = TimingSimpleCPU()
elif args.cpu_type == "minor":
    system.cpu = MinorCPU()
else:
    # Detailed Out-of-Order Superscalar CPU
    system.cpu = O3CPU()
    system.cpu.fetchWidth = args.width
    system.cpu.decodeWidth = args.width
    system.cpu.renameWidth = args.width
    system.cpu.issueWidth = args.width
    system.cpu.dispatchWidth = args.width
    system.cpu.wbWidth = args.width
    system.cpu.commitWidth = args.width
    system.cpu.backComSize = 10
    system.cpu.forwardComSize = 10

    # Branch Predictor Selection
    if args.bp_type == "2BitLocal" or args.bp_type == "LocalBP":
        system.cpu.branchPred = BranchPredictor(
            conditionalBranchPred=LocalBP()
            )
    elif args.bp_type == "TournamentBP":
        system.cpu.branchPred = BranchPredictor(
            conditionalBranchPred=TournamentBP()
            )
    elif args.bp_type == "BiModeBP":
        system.cpu.branchPred = BranchPredictor(
            conditionalBranchPred=BiModeBP()
            )

# Custom L1 Cache Subclasses
class L1ICache(Cache):
    size = '32KiB'
    assoc = 2
    tag_latency = 2
    data_latency = 2
    response_latency = 2
    mshrs = 4
    tgts_per_mshr = 20

class L1DCache(Cache):
    size = '32KiB'
    assoc = 2
    tag_latency = 2
    data_latency = 2
    response_latency = 2
    mshrs = 4
    tgts_per_mshr = 20

# Instantiate Caches
system.cpu.icache = L1ICache()
system.cpu.dcache = L1DCache()

# Crossbar & Port Connections
system.membus = SystemXBar()
system.cpu.icache.cpu_side = system.cpu.icache_port
system.cpu.icache.mem_side = system.membus.cpu_side_ports
system.cpu.dcache.cpu_side = system.cpu.dcache_port
system.cpu.dcache.mem_side = system.membus.cpu_side_ports

# Memory Controller Setup (DDR3)
system.mem_ctrl = MemCtrl()
system.mem_ctrl.dram = DDR3_1600_8x8()
system.mem_ctrl.dram.range = system.mem_ranges[0]
system.mem_ctrl.port = system.membus.mem_side_ports

# Interrupt Controller Setup
system.cpu.createInterruptController()
if "int_requestor" in system.cpu.ArchInterrupts._ports:
    for interrupt in system.cpu.interrupts:
        interrupt.pio = system.membus.mem_side_ports
        interrupt.int_requestor = system.membus.cpu_side_ports
        interrupt.int_responder = system.membus.mem_side_ports

system.system_port = system.membus.cpu_side_ports

# Workload Process Setup
process = Process()
process.cmd = [args.cmd, args.options]
system.cpu.workload = process
system.cpu.createThreads()

system.workload = SEWorkload.init_compatible(args.cmd)

# Root Simulation Control
root = Root(full_system=False, system=system)
m5.instantiate()

print(f"Starting simulation: CPU={args.cpu_type}, Width={args.width}, BP={args.bp_type}")
exit_event = m5.simulate()
print(f"Exiting @ tick {m5.curTick()} because {exit_event.getCause()}")