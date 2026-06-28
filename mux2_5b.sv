module mux2_5b (
    input  logic       sel,
    input  logic [4:0] in0,
    input  logic [4:0] in1,
    output logic [4:0] out
);

    always_comb
        out = sel ? in1 : in0;

endmodule