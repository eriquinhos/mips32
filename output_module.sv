module output_module (
    input  logic        clk,
    input  logic        ctrl_out,       // 0 = show data_in, 1 = show switches
    input  logic [7:0]  switches,
    input  logic [31:0] data_in,
    output logic [6:0]  seg1, seg2, seg3, seg4, seg5
);

    logic [31:0] d1, d2, d3, d4, d5;
    logic [31:0] tmp;

    initial begin
        d1 = 32'd15; d2 = 32'd15;
        d3 = 32'd15; d4 = 32'd15; d5 = 32'd15;
    end

    always @(*) begin
        tmp = ctrl_out ? 32'(switches) : data_in;

        if (tmp > 32'd99999) begin
            d1 = 32'd14; d2 = 32'd14;
            d3 = 32'd14; d4 = 32'd14; d5 = 32'd14;
        end else begin
            d1 = tmp % 10; tmp = tmp / 10;
            d2 = tmp % 10; tmp = tmp / 10;
            d3 = tmp % 10; tmp = tmp / 10;
            d4 = tmp % 10; tmp = tmp / 10;
            d5 = tmp % 10;
        end
    end

    // 7-segment decoder instances
    seven_seg_decoder disp1 (.digit(d1[3:0]), .segments(seg1));
    seven_seg_decoder disp2 (.digit(d2[3:0]), .segments(seg2));
    seven_seg_decoder disp3 (.digit(d3[3:0]), .segments(seg3));
    seven_seg_decoder disp4 (.digit(d4[3:0]), .segments(seg4));
    seven_seg_decoder disp5 (.digit(d5[3:0]), .segments(seg5));

endmodule