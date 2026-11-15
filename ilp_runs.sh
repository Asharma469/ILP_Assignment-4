#!/bin/bash
set -e

GEM5_BIN="$HOME/gem5/build/X86/gem5.opt"
SCRIPT="ilp_sim.py"
OUT_DIR="results_ilp"

mkdir -p $OUT_DIR

echo "=== Starting gem5 ILP Experiment Suite ==="

# 1. Baseline CPU Architecture Comparison
echo "[Run 1/7] In-Order Baseline (TimingSimpleCPU)..."
$GEM5_BIN -d $OUT_DIR/run1_timing $SCRIPT --cpu_type=timing --options="1"

echo "[Run 2/7] Out-of-Order Baseline (O3CPU, 4-issue, TournamentBP)..."
$GEM5_BIN -d $OUT_DIR/run2_o3_base $SCRIPT --cpu_type=o3 --width=4 --bp_type=TournamentBP --options="1"

# 2. Branch Predictor Sweeps (O3CPU)
echo "[Run 3/7] O3CPU with 2-Bit Local Branch Predictor..."
$GEM5_BIN -d $OUT_DIR/run3_bp_local $SCRIPT --cpu_type=o3 --width=4 --bp_type=2BitLocal --options="1"

echo "[Run 4/7] O3CPU with BiMode Branch Predictor..."
$GEM5_BIN -d $OUT_DIR/run4_bp_bimode $SCRIPT --cpu_type=o3 --width=4 --bp_type=BiModeBP --options="1"

# 3. Superscalar Issue Width Scaling (O3CPU)
echo "[Run 5/7] O3CPU 1-Issue Width..."
$GEM5_BIN -d $OUT_DIR/run5_w1 $SCRIPT --cpu_type=o3 --width=1 --bp_type=TournamentBP --options="1"

echo "[Run 6/7] O3CPU 2-Issue Width..."
$GEM5_BIN -d $OUT_DIR/run6_w2 $SCRIPT --cpu_type=o3 --width=2 --bp_type=TournamentBP --options="1"

echo "[Run 7/7] O3CPU 8-Issue Width..."
$GEM5_BIN -d $OUT_DIR/run7_w8 $SCRIPT --cpu_type=o3 --width=8 --bp_type=TournamentBP --options="1"

echo "=== All ILP Simulations Complete! ==="