#!/bin/bash

# Source the OSS CAD Suite environment
echo "Sourcing OSS CAD Suite environment..."
source ~/oss-cad-suite/environment
if [ $? -ne 0 ]; then
    echo "Failed to source OSS CAD Suite environment. Exiting script."
    exit 1
fi

# Run the testbench using the Makefile
python test_runner.py 