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

echo "=========================================================================================================="
echo -e "Run Directory\t\t| IPC\t\t| simTicks\t\t| Committed Insts\t| Branch Mispreds"
echo "=========================================================================================================="

for r in "$RESULTS_DIR"/run*; do
    if [ -d "$r" ]; then
        folder=$(basename "$r")
        
        ipc=$(grep -E "system\.cpu\.ipc::total|system\.cpu\.ipc" "$r/stats.txt" 2>/dev/null | awk '{print $2}' | head -n 1)
        ticks=$(grep -E "^simTicks" "$r/stats.txt" 2>/dev/null | awk '{print $2}' | head -n 1)
        insts=$(grep -E "^simInsts" "$r/stats.txt" 2>/dev/null | awk '{print $2}' | head -n 1)
        mispred=$(grep -E "branchPred\.condIncorrect" "$r/stats.txt" 2>/dev/null | awk '{print $2}' | head -n 1)

        # Fallback formatting if stats are empty
        ipc=${ipc:-"N/A"}
        ticks=${ticks:-"N/A"}
        insts=${insts:-"N/A"}
        mispred=${mispred:-"0"}

        printf "%-23s | %-12s | %-20s | %-21s | %-15s\n" "$folder" "$ipc" "$ticks" "$insts" "$mispred"
    fi
done
echo "=========================================================================================================="