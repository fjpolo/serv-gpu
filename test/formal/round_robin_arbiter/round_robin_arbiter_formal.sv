module round_robin_arbiter #(parameter NUM_CORES = 1) (
    input wire clk,
    input wire rst,
    input wire [NUM_CORES-1:0] req,
    output reg [NUM_CORES-1:0] grant
);

    generate
        if (NUM_CORES > 1) begin : multi_core
            reg [$clog2(NUM_CORES)-1:0] priority_reg; // Only declare when NUM_CORES > 1

            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    grant <= {NUM_CORES{1'b0}};
                    priority_reg <= 0;
                end else begin
                    // Rotate priority
                    priority_reg <= (priority_reg + 1) % NUM_CORES;
                    // Grant access to the next requesting core
                    grant <= {NUM_CORES{1'b0}};
                    if (req[priority_reg])
                        grant[priority_reg] <= 1'b1;
                end
            end
        end else begin : single_core
            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    grant <= {NUM_CORES{1'b0}};
                end else begin
                    grant <= req;
                end
            end
        end
    endgenerate

`ifdef	FORMAL
// Change direction of assumes
`define	ASSERT	assert
`ifdef	ROUND_ROBIN_ARBITER
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