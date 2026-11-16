# ILP Assignment 4

This project uses [gem5](https://www.gem5.org/) to explore instruction-level parallelism (ILP) by simulating a strided array workload on different CPU models and configurations. It compares an in-order timing CPU with an out-of-order O3 CPU, varies the O3 issue width, and tests branch predictors.

## Code overview

- `array_stride.c` implements the workload: it initializes a 128K-integer array, then performs five passes of strided reads and updates. The optional command-line argument sets the stride (default: `1`).
- `ilp_sim.py` is the gem5 configuration. It selects the CPU and branch predictor, applies the O3 width, sets up 32 KiB L1 instruction and data caches, connects memory and a DDR3 controller, and launches the workload in syscall-emulation mode.
- `ilp_runs.sh` runs seven predefined experiments: a TimingSimpleCPU baseline; O3 baselines with different predictors; and O3 width settings of 1, 2, 4, and 8.
- `results_ilp/` contains gem5 output directories, including per-run `stats.txt` files.

## Requirements

- A compiled X86 gem5 binary at `$HOME/gem5/build/X86/gem5.opt`.
- A C compiler such as `gcc`.

The commands below assume the terminal is in the project directory.

## Build and run

Compile the workload binary expected by the gem5 configuration:

```bash
gcc -O2 -o stride_output array_stride.c
```

Run one simulation directly (TimingSimpleCPU example):

```bash
$HOME/gem5/build/X86/gem5.opt -d results_ilp/run1_timing \
  ilp_sim.py --cpu_type=timing --options=1
```

Run an O3 simulation with a 4-wide pipeline and Tournament branch predictor:

```bash
$HOME/gem5/build/X86/gem5.opt -d results_ilp/run2_o3_base \
  ilp_sim.py --cpu_type=o3 --width=4 --bp_type=TournamentBP --options=1
```

To run the full seven-experiment suite:

```bash
bash ilp_runs.sh
```

The script uses `set -e` and stops if a simulation fails. To execute it directly instead, make it executable once with `chmod +x ilp_runs.sh`, then run `./ilp_runs.sh`.

## Configuration options

- `--cpu_type`: `timing`, `minor`, or `o3` (default: `o3`).
- `--width`: O3 fetch/decode/rename/issue/dispatch/writeback/commit width (default: `4`).
- `--bp_type`: O3 branch predictor, `LocalBP` (also accepted as `2BitLocal`), `TournamentBP`, or `BiModeBP`.
- `--cmd`: workload executable path (default: `./stride_output`).
- `--options`: workload argument string, passed as the stride (default: `1`).

For example, change the stride to 16 with `--options=16`. Each run writes gem5 output to the directory passed to `-d`; inspect that run's `stats.txt` to compare performance statistics.
