`timescale 1ns/1ps

module tb_fibonacci_io;

    logic       real_clk;
    logic       key;
    logic       rst;
    logic [7:0] data_in;
    logic [9:0] state;
    logic [6:0] seg5, seg4, seg3, seg2, seg1;

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

    task automatic pulse_key();
        begin
            key = 1'b1;
            repeat (2) @(posedge real_clk);
            key = 1'b0;
            repeat (2) @(posedge real_clk);
        end
    endtask

    initial begin
        rst     = 1'b1;
        key     = 1'b0;
        data_in = 8'd26;

        repeat (20) @(posedge real_clk);
        rst = 1'b0;

        repeat (2) @(posedge real_clk);
        pulse_key();

        forever begin
            repeat (50) @(posedge real_clk);
            pulse_key();
        end
    end

    initial begin
        repeat (500000) @(posedge real_clk);
        $stop;
    end

endmodule