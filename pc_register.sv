module pc_register (
    input  logic        clk,
    input  logic        reset,
    input  logic        write_en,
    input  logic [31:0] in,
    output logic [31:0] out,
    output logic [9:0]  leds
);

    always_ff @(posedge clk) begin
        if (reset)          out <= 32'd0;
        else if (write_en)  out <= in;
        leds <= out[9:0];
    end

endmodule