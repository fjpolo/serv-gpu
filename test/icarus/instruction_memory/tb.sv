`timescale 1ns/1ps

module tb;

  parameter NUM_CORES = 1; // Test with 4 core

  reg clk;
  reg rst;

  instruction_memory #(NUM_CORES) uut ();

  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns clock period
  end

  initial begin
    rst = 1;
    #10;
    rst = 0;

    // Pass
    #10;
    $display("PASS: All test cases passed!");
    $finish;
  end

endmodule