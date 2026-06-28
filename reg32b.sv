module reg32b (
    input  logic        clk,
    input  logic        write_en,
    input  logic [31:0] in,
    output logic [31:0] out
);

    always_ff @(posedge clk)  //synchronous write enable
        if (write_en) out <= in;

endmodule