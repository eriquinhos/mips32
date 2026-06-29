`timescale 1ns/1ps

module tb_bubble_sort;

    localparam logic [4:0] S_IN  = 5'd12;
    localparam logic [4:0] S_OUT = 5'd20;

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

    wire [4:0] cu_state = uut.cpu.ctrl_unit.state_r;

    initial real_clk = 1'b0;
    always #5 real_clk = ~real_clk;

    task automatic pulse_key();
        begin
            key = 1'b1;
            repeat (30) @(posedge real_clk);
            key = 1'b0;
            repeat (30) @(posedge real_clk);
        end
    endtask

    task automatic wait_state(input logic [4:0] s);
        begin
            while (cu_state !== s) @(posedge real_clk);
        end
    endtask

    task automatic wait_not_state(input logic [4:0] s);
        begin
            while (cu_state === s) @(posedge real_clk);
        end
    endtask

    initial begin
        rst     = 1'b1;
        key     = 1'b0;
        data_in = 8'd0;

        repeat (20) @(posedge real_clk);
        rst = 1'b0;

        // 5 entradas
        data_in = 8'd45;
        wait_state(S_IN);
        pulse_key();
        wait_not_state(S_IN);

        data_in = 8'd255;
        wait_state(S_IN);
        pulse_key();
        wait_not_state(S_IN);

        data_in = 8'd76;
        wait_state(S_IN);
        pulse_key();
        wait_not_state(S_IN);

        data_in = 8'd190;
        wait_state(S_IN);
        pulse_key();
        wait_not_state(S_IN);

        data_in = 8'd32;
        wait_state(S_IN);
        pulse_key();
        wait_not_state(S_IN);

        // libera os 5 OUTs
        repeat (5) begin
            wait_state(S_OUT);
            pulse_key();
            wait_not_state(S_OUT);
        end

        repeat (2000) @(posedge real_clk);
        $stop;
    end

    initial begin
        repeat (2000000) @(posedge real_clk);
        $stop;
    end

endmodule