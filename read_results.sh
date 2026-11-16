#!/bin/bash

RESULTS_DIR="./results_ilp"

if [ ! -d "$RESULTS_DIR" ]; then
    echo "Directory $RESULTS_DIR does not exist."
    exit 1
fi

for r in "$RESULTS_DIR"/run3_bp_local "$RESULTS_DIR"/run2_o3_base "$RESULTS_DIR"/run4_bp_bimode; do
    echo "=== $r ==="
    grep -E "system\\.cpu\\.ipc|simTicks|branchPred\\.condIncorrect" "$r/stats.txt"
done
