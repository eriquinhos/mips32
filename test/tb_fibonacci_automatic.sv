`timescale 1ns/1ps

module tb_fibonacci;

    logic        real_clk;
    logic        key;
    logic        rst;
    logic [7:0]  data_in;
    logic [9:0]  state;
    logic [6:0]  seg5, seg4, seg3, seg2, seg1;

    mips32 uut (
        .real_clk (real_clk),
        .key      (key),
        .rst      (rst),
        .data_in  (data_in),
        .state    (state),
        .seg5     (seg5),
        .seg4     (seg4),
        .seg3     (seg3),
        .seg2     (seg2),
        .seg1     (seg1)
    );

    initial real_clk = 1'b0;
    always #5 real_clk = ~real_clk;

    initial begin
        rst     = 1'b1;
        key     = 1'b1;
        data_in = 8'd0;

        repeat (10) @(posedge real_clk);
        rst = 1'b0;

        repeat (200000) @(posedge real_clk);
        $stop;
    end

endmodule