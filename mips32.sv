module mips32 (
    input  logic        real_clk,
    input  logic        key,
    input  logic        rst,
    input  logic [7:0]  data_in,
    output logic [9:0]  state,
    output logic [6:0]  seg5,
    output logic [6:0]  seg4,
    output logic [6:0]  seg3,
    output logic [6:0]  seg2,
    output logic [6:0]  seg1
);

    logic        ctrl_out;
    logic [31:0] bus;

    processor cpu (
        .real_clk (real_clk),
        .key      (key),
        .rst      (rst),
        .data_in  (data_in),
        .state    (state),
        .data_out (bus),
        .ctrl_in  (),
        .ctrl_out (ctrl_out)
    );

    output_module out_mod (
        .clk      (real_clk),
        .ctrl_out (ctrl_out),
        .switches (data_in),
        .data_in  (bus),
        .seg1     (seg1),
        .seg2     (seg2),
        .seg3     (seg3),
        .seg4     (seg4),
        .seg5     (seg5)
    );

endmodule