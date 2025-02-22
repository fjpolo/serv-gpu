`default_nettype none

module top(
    input   wire            clk,
    input   wire            reset_button_n,
    output  wire    [5:0]   leds
);

wire [31:0] data_out;

serv_gpu serv_gpu_instance(
    .clk(clk),
    .rst(!reset_button_n),
    .o_data(data_out)
);

assign leds = !data_out[5:0];

endmodule
