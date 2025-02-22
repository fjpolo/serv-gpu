# !/bin/bash

# Welcome!
echo "Running Formal Verification using SBY..."

# barrier_sync
echo "Veryfying barrier_sync..."
cd barrier_sync/
./run.sh > barrier_sync_log.txt
cd ..
if [ $? -ne 0 ]; then
    echo "FAIL: sby failed for original barrier_sync. Exiting script."
    exit 1
fi
echo "Done!"

# instruction_memory
echo "Veryfying instruction_memory..."
cd instruction_memory/
./run.sh > instruction_memory_log.txt
cd ..
if [ $? -ne 0 ]; then
    echo "FAIL: sby failed for original instruction_memory. Exiting script."
    exit 1
fi
echo "Done!"

# round_robin_arbiter
echo "Veryfying round_robin_arbiter..."
cd round_robin_arbiter/
./run.sh > round_robin_arbiter_log.txt
cd ..
if [ $? -ne 0 ]; then
    echo "FAIL: sby failed for original round_robin_arbiter. Exiting script."
    exit 1
fi
echo "Done!"

# shared_memory
echo "Veryfying shared_memory..."
cd shared_memory/
./run.sh > shared_memory_log.txt
cd ..
if [ $? -ne 0 ]; then
    echo "FAIL: sby failed for original shared_memory. Exiting script."
    exit 1
fi
echo "Done!"

# Chau chau!
echo "Formal Verification: PASS!"