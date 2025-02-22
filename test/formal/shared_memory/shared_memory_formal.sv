module shared_memory (
    input wire clk,
    input wire [31:0] addr,
    input wire [31:0] data_in,
    input wire we,
    output reg [31:0] data_out
);

    // Define a memory array (1 kB for this example)
    reg [31:0] mem [0:255];

    // Initialize memory with test data
    initial begin
        // Initialize input data (data[0:15])
        for (integer i = 0; i < 16; i = i + 1)
            mem[i] = i + 1;  // Example: data[i] = i + 1
        // Initialize output data (data[16:31]) to 0
        for (integer i = 16; i < 32; i = i + 1)
            mem[i] = 0;
    end

    // Read/write from memory
    always @(posedge clk) begin
        if (we)
            mem[addr] <= data_in;  // Write
        data_out <= mem[addr];     // Read
    end

`ifdef	FORMAL
// Change direction of assumes
`define	ASSERT	assert
`ifdef	SHARED_MEMORY
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
