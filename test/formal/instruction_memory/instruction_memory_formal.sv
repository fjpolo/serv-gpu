module instruction_memory (
    input wire clk,
    input wire [31:0] addr,
    output reg [31:0] data_out
);

    // Define a memory array (1 kB for this example)
    reg [31:0] mem [0:255];

    // Initialize memory with the vector addition program
    initial begin
        // Program for vector addition
        mem[0] = 32'h00500093;  // li x1, 5          (Core ID)
        mem[1] = 32'h00800113;  // li x2, 8          (Offset for second input)
        mem[2] = 32'h01000193;  // li x3, 16         (Offset for output)
        mem[3] = 32'h00008233;  // add x4, x1, x0    (data[core_id])
        mem[4] = 32'h002102b3;  // add x5, x1, x2    (data[core_id + 8])
        mem[5] = 32'h00318333;  // add x6, x1, x3    (data[core_id + 16])
        mem[6] = 32'h00022383;  // lw x7, 0(x4)      (Load data[core_id])
        mem[7] = 32'h0002a403;  // lw x8, 0(x5)      (Load data[core_id + 8])
        mem[8] = 32'h008383b3;  // add x9, x7, x8    (Add data[core_id] + data[core_id + 8])
        mem[9] = 32'h00932023;  // sw x9, 0(x6)      (Store result in data[core_id + 16])
        mem[10] = 32'hffdff06f; // j _start          (Infinite loop)

        // Fill the rest of memory with zeros (optional)
        for (integer i = 11; i < 256; i = i + 1)
            mem[i] = 32'h00000000;
    end

    // Read from memory
    always @(posedge clk) begin
        data_out <= mem[addr];
    end

`ifdef	FORMAL
// Change direction of assumes
`define	ASSERT	assert
`ifdef	INSTRUCTION_MEMORY
`define	ASSUME	assume
`else
`define	ASSUME	assert
`endif

	////////////////////////////////////////////////////
	//
	// f_past_valid register
	//
	////////////////////////////////////////////////////
	reg	f_past_valid;
	initial	f_past_valid = 0;
	always @(posedge i_clk)
		f_past_valid <= 1'b1;

	////////////////////////////////////////////////////
	//
	// Reset
	//
	////////////////////////////////////////////////////

	////////////////////////////////////////////////////
	//
	// BMC
	//
	////////////////////////////////////////////////////

	////////////////////////////////////////////////////
	//
	// Contract
	//
	////////////////////////////////////////////////////   

	////////////////////////////////////////////////////
	//
	// Induction
	//
	////////////////////////////////////////////////////
	
	////////////////////////////////////////////////////
	//
	// Cover
	//
	////////////////////////////////////////////////////     

`endif // FORMAL

endmodule
