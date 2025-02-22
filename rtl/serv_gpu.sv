`default_nettype none

module serv_gpu #(
                    parameter       NUM_CORES = 1,
                    parameter	    WITH_CSR = 1,
                    parameter	    W = 1,
                    parameter	    B = W-1,
                    parameter	    PRE_REGISTER = 1,
                    parameter	    RESET_STRATEGY = "MINI",
                    parameter	    RESET_PC = 32'd0,
                    parameter [0:0] DEBUG = 1'b0,
                    parameter [0:0] MDU = 1'b0,
                    parameter [0:0] COMPRESSED=0,
                    parameter [0:0] ALIGN = COMPRESSED
    )(
    input   wire    [0:0]   clk,
    input   wire    [0:0]   rst,
    output  wire    [31:0]  o_data,
    output  wire    [0:0]   o_all_done
    );

    // Reset signal
    wire i_rst;
    assign i_rst = rst;

    // Instruction memory interface
    wire [31:0] instr_addr [NUM_CORES-1:0];
    wire [31:0] instr_data [NUM_CORES-1:0];
    wire [NUM_CORES-1:0] instr_cyc;
    wire [NUM_CORES-1:0] instr_ack;

    // Data memory interface
    wire [31:0] data_addr [NUM_CORES-1:0];
    wire [31:0] data_in [NUM_CORES-1:0];
    wire [31:0] data_out [NUM_CORES-1:0];
    wire [NUM_CORES-1:0] data_we;
    wire [NUM_CORES-1:0] data_cyc;
    wire [NUM_CORES-1:0] data_ack;

    // Arbiter signals
    wire [NUM_CORES-1:0] data_req;
    wire [NUM_CORES-1:0] data_grant;

    // Core completion signals
    wire [NUM_CORES-1:0] core_done;
    wire all_done;

    // Instantiate the shared instruction memory
    instruction_memory instr_mem (
        .clk(clk),
        .addr(instr_addr[0]),     // All cores share the same instruction memory
        .data_out(instr_data[0])
    );

    // Instantiate the shared data memory
    shared_memory data_mem (
        .clk(clk),
        .addr(data_addr[0]),     // All cores share the same data memory
        .data_in(data_in[0]),
        .we(data_we[0]),
        .data_out(data_out[0])
    );

    // Instantiate the round-robin arbiter
    round_robin_arbiter #(NUM_CORES) arbiter_inst (
        .clk(clk),
        .rst(i_rst),
        .req(data_req),
        .grant(data_grant)
    );

    // Instantiate the barrier synchronization
    barrier_sync #(NUM_CORES) sync_inst (
        .clk(clk),
        .rst(i_rst),
        .core_done(core_done),
        .all_done(all_done)
    );

    // Instantiate SERV cores
    wire [3:0] 	        dbus_sel;
    wire 		        rf_rreq;
    wire 		        rf_wreq;
    wire [4+WITH_CSR:0] wreg0;
    wire [4+WITH_CSR:0] wreg1;
    wire 		        wen0;
    wire 		        wen1;
    wire [B:0]          wdata0;
    wire [B:0]          wdata1;
    wire [4+WITH_CSR:0] rreg0;
    wire [4+WITH_CSR:0] rreg1;
    wire [ 2:0]         ext_funct3;
    wire                ext_ready;
    wire  [31:0]        ext_rd;
    wire [31:0]         ext_rs1;
    wire [31:0]         ext_rs2;
    wire                mdu_valid;
    genvar i;
    generate
        for (i = 0; i < NUM_CORES; i = i + 1) begin : core_gen
            // SERV core instance
            serv_top serv_top_inst(
                .clk(clk),
                .i_rst(i_rst),
                .i_timer_irq(1'b0),  // No timer interrupt
                .o_ibus_adr(instr_addr[i]),
                .o_ibus_cyc(instr_cyc[i]),
                .i_ibus_rdt(instr_data[i]),
                .i_ibus_ack(instr_ack[i]),
                .o_dbus_adr(data_addr[i]),
                .o_dbus_dat(data_in[i]),
                .o_dbus_sel(dbus_sel),
                .o_dbus_we(data_we[i]),
                .o_dbus_cyc(data_cyc[i]),
                .i_dbus_rdt(data_out[i]),
                .i_dbus_ack(data_ack[i]),
                .o_rf_rreq(rf_rreq),
                .o_rf_wreq(rf_wreq),
                .i_rf_ready(1'b1),      // Always ready
                .o_wreg0(wreg0), 
                .o_wreg1(wreg1), 
                .o_wen0(wen0),  
                .o_wen1(wen1),  
                .o_wdata0(wdata0),
                .o_wdata1(wdata1),
                .o_rreg0(rreg0), 
                .o_rreg1(rreg1), 
                .i_rdata0(1'b0),        // Explicitly tie to 0
                .i_rdata1(1'b0),        // Explicitly tie to 0
                .o_ext_funct3(ext_funct3),
                .i_ext_ready(1'b0),
                .i_ext_rd('h0),
                .o_ext_rs1(ext_rs1),
                .o_ext_rs2(ext_rs2),
                .o_mdu_valid(mdu_valid)
            );

            // Core completion signal (example: set when core finishes its task)
            assign core_done[i] = (data_addr[i] == 32'hFFFFFFFF);  // Example condition

            // Memory arbitration
            assign data_req[i] = data_cyc[i];
            assign data_ack[i] = data_grant[i];
        end
    endgenerate
    
    // Output
    assign o_data = data_out[0];

endmodule
