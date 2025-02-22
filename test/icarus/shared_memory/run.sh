# !/bin/bash

# Environmental Variables
RTL_PATH="../../../rtl"
MODULE_NAME="shared_memory"
ORIGINAL_FILE="$RTL_PATH/${MODULE_NAME}.sv"
ICARUS_TB_FILE="${MODULE_NAME}_tb.sv"
ICARUS_OUTPUT_FILE="${MODULE_NAME}__out"
SIMULATOR="iverilog"

# Run simulation of slave_tb.v with the original slave.v
echo "Running simulation for $MODULE_NAME..."
cp $ORIGINAL_FILE .
echo "${MODULE_NAME}.sv"
$SIMULATOR -o ${ICARUS_OUTPUT_FILE} ${MODULE_NAME}.sv ${ICARUS_TB_FILE}
if [ $? -ne 0 ]; then
    echo "Simulation compilation failed for $MODULE_NAME. Exiting script."
    rm -f ${ICARUS_OUTPUT_FILE}
    rm -f ${MODULE_NAME}.sv
    exit 1
fi

# Execute the simulation and check the exit status
./${ICARUS_OUTPUT_FILE}
SIM_EXIT_STATUS=$?
if [ $SIM_EXIT_STATUS -ne 0 ]; then
    echo "Simulation failed for $MODULE_NAME with exit status $SIM_EXIT_STATUS. Exiting script."
    rm -f ${ICARUS_OUTPUT_FILE}
    rm -f ${MODULE_NAME}.sv
    exit 1
fi
rm -f ${MODULE_NAME}.sv

# Clean up the simulation executable
rm -f ${ICARUS_OUTPUT_FILE}