#!/bin/bash

# Create virtualenv with cocotb


# Run the testbench using the Makefile
make run

# Check the exit status of the testbench
if [ $? -eq 0 ]; then
    echo "All tests passed!"
else
    echo "Some tests failed."
fi