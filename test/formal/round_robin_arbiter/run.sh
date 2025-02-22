#!/bin/bash

# Source the OSS CAD Suite environment
echo "Sourcing OSS CAD Suite environment..."
source ~/oss-cad-suite/environment
if [ $? -ne 0 ]; then
    echo "Failed to source OSS CAD Suite environment. Exiting script."
    exit 1
fi

# Environmental Variables
RTL_PATH="../../../rtl"
MODULE_NAME="round_robin_arbiter"
ORIGINAL_FILE="$RTL_PATH/${MODULE_NAME}.sv"
FORMAL_PROPERTIES_FILE="${MODULE_NAME}_properties.sv"
TEMP_FILE="${MODULE_NAME}_formal.sv"
FORMAL_RUNNER="sby"

# Check if required files exist
echo "Checking if required files exist..."
for FILE in "$ORIGINAL_FILE" "$FORMAL_PROPERTIES_FILE"; do
    if [ ! -f "$FILE" ]; then
        echo "Error: File $FILE not found. Exiting script."
        exit 1
    fi
done

# Insert formal properties into the original slave.v before `endmodule`
sed "/endmodule/e cat $FORMAL_PROPERTIES_FILE" $ORIGINAL_FILE > $TEMP_FILE

#
# Formal Verification
#

# Verify the original slave.v with formal properties
# Run SymbiYosys (sby) on the temporary file
echo "Verifying original $ORIGINAL_FILE with formal properties..."
sby -f ${MODULE_NAME}.sby
# Check if sby succeeded
if [ $? -ne 0 ]; then
    echo "sby failed for original slave.v. Exiting script."
    rm $SLAVE_TEMP_ORIGINAL_FILE
    exit 1
fi